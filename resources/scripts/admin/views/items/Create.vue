<template>
  <BasePage>
    <BasePageHeader :title="pageTitle">
      <BaseBreadcrumb>
        <BaseBreadcrumbItem :title="$t('general.home')" to="dashboard" />
        <BaseBreadcrumbItem :title="$tc('items.item', 2)" to="/admin/items" />
        <BaseBreadcrumbItem :title="pageTitle" to="#" active />
      </BaseBreadcrumb>
    </BasePageHeader>

    <ItemUnitModal />

    <form
      class="grid lg:grid-cols-2 mt-6"
      action="submit"
      @submit.prevent="submitItem"
    >
      <BaseCard class="w-full">
        <BaseInputGrid layout="one-column">
          <BaseInputGroup
            :label="$t('items.name')"
            :content-loading="isFetchingInitialData"
            required
            :error="
              v$.currentItem.name.$error &&
              v$.currentItem.name.$errors[0].$message
            "
          >
            <BaseInput
              v-model="itemStore.currentItem.name"
              :content-loading="isFetchingInitialData"
              :invalid="v$.currentItem.name.$error"
              @input="v$.currentItem.name.$touch()"
            />
            <div class="mt-2 flex items-center gap-3 flex-wrap">
              <BarcodeScanner @scanned="onBarcodeScanned" />
              <CustomFieldsManager ref="cfManagerRef" @vue:mounted="loadFieldTemplates" />
            </div>
          </BaseInputGroup>

          <BaseInputGroup
            :label="$t('items.price')"
            :content-loading="isFetchingInitialData"
          >
            <BaseMoney
              v-model="price"
              :content-loading="isFetchingInitialData"
            />
          </BaseInputGroup>

          <BaseInputGroup
            :content-loading="isFetchingInitialData"
            :label="$t('items.unit')"
          >
            <BaseMultiselect
              v-model="itemStore.currentItem.unit_id"
              :content-loading="isFetchingInitialData"
              label="name"
              :options="itemStore.itemUnits"
              value-prop="id"
              :placeholder="$t('items.select_a_unit')"
              searchable
              track-by="name"
            >
              <template #action>
                <BaseSelectAction @click="addItemUnit">
                  <BaseIcon
                    name="PlusIcon"
                    class="h-4 mr-2 -ml-2 text-center text-primary-400"
                  />
                  {{ $t('settings.customization.items.add_item_unit') }}
                </BaseSelectAction>
              </template>
            </BaseMultiselect>
          </BaseInputGroup>

          <BaseInputGroup
            v-if="isTaxPerItem"
            :label="$t('items.taxes')"
            :content-loading="isFetchingInitialData"
          >
            <BaseMultiselect
              v-model="taxes"
              :content-loading="isFetchingInitialData"
              :options="getTaxTypes"
              mode="tags"
              label="tax_name"
              class="w-full"
              value-prop="id"
              :can-deselect="false"
              :can-clear="false"
              searchable
              track-by="tax_name"
              object
            />
          </BaseInputGroup>

          <BaseInputGroup
            :label="$t('items.description')"
            :content-loading="isFetchingInitialData"
            :error="
              v$.currentItem.description.$error &&
              v$.currentItem.description.$errors[0].$message
            "
          >
            <BaseTextarea
              v-model="itemStore.currentItem.description"
              :content-loading="isFetchingInitialData"
              name="description"
              :row="2"
              rows="2"
              @input="v$.currentItem.description.$touch()"
            />
          </BaseInputGroup>

          <!-- Custom Fields Section -->
          <div v-if="customFieldTemplates.length > 0">
            <p class="text-sm font-semibold text-gray-700 mb-3">
              Additional Details
            </p>
            <div class="space-y-3">
              <div
                v-for="(field, idx) in itemStore.currentItem.custom_fields"
                :key="field.key"
              >
                <label class="block text-xs font-medium text-gray-600 mb-1">{{ field.label }}</label>
                <textarea
                  v-if="field.type === 'textarea'"
                  v-model="field.value"
                  rows="2"
                  class="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-300"
                />
                <input
                  v-else
                  v-model="field.value"
                  :type="field.type"
                  class="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-300"
                />
              </div>
            </div>
          </div>

          <div>
            <BaseButton
              :content-loading="isFetchingInitialData"
              type="submit"
              :loading="isSaving"
            >
              <template #left="slotProps">
                <BaseIcon
                  v-if="!isSaving"
                  name="SaveIcon"
                  :class="slotProps.class"
                />
              </template>

              {{ isEdit ? $t('items.update_item') : $t('items.save_item') }}
            </BaseButton>
          </div>
        </BaseInputGrid>
      </BaseCard>
    </form>
  </BasePage>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import {
  required,
  minLength,
  numeric,
  minValue,
  maxLength,
  helpers,
} from '@vuelidate/validators'
import useVuelidate from '@vuelidate/core'
import { useItemStore } from '@/scripts/admin/stores/item'
import { useCompanyStore } from '@/scripts/admin/stores/company'
import { useTaxTypeStore } from '@/scripts/admin/stores/tax-type'
import { useModalStore } from '@/scripts/stores/modal'
import ItemUnitModal from '@/scripts/admin/components/modal-components/ItemUnitModal.vue'
import BarcodeScanner from '@/scripts/admin/components/BarcodeScanner.vue'
import CustomFieldsManager from '@/scripts/admin/components/CustomFieldsManager.vue'
import { useUserStore } from '@/scripts/admin/stores/user'
import abilities from '@/scripts/admin/stub/abilities'

const itemStore = useItemStore()
const taxTypeStore = useTaxTypeStore()
const modalStore = useModalStore()
const companyStore = useCompanyStore()
const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const isSaving = ref(false)
const cfManagerRef = ref(null)
const STORAGE_KEY = 'synergy_item_custom_field_templates'

const customFieldTemplates = ref([])

function loadFieldTemplates() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    customFieldTemplates.value = saved ? JSON.parse(saved) : []
  } catch {
    customFieldTemplates.value = []
  }
  // Sync with currentItem.custom_fields — preserve existing values, add missing fields
  const existing = itemStore.currentItem.custom_fields || []
  itemStore.currentItem.custom_fields = customFieldTemplates.value.map((tpl) => {
    const found = existing.find((f) => f.key === tpl.key)
    return { key: tpl.key, label: tpl.label, type: tpl.type, value: found ? found.value : '' }
  })
}

onMounted(() => {
  loadFieldTemplates()
  // Re-sync whenever localStorage changes (e.g. user adds a field in manager)
  window.addEventListener('storage', loadFieldTemplates)
})

function onBarcodeScanned({ raw, parsed }) {
  // Fill name
  if (parsed && parsed.name) {
    itemStore.currentItem.name = parsed.name
  } else {
    itemStore.currentItem.name = raw
  }
  v$.value.currentItem.name.$touch()

  // Auto-fill custom fields if QR contained JSON with matching keys
  if (parsed) {
    itemStore.currentItem.custom_fields = itemStore.currentItem.custom_fields.map((field) => {
      if (parsed[field.key] !== undefined) {
        return { ...field, value: String(parsed[field.key]) }
      }
      return field
    })
  }
}
const taxPerItem = ref(companyStore.selectedCompanySettings.tax_per_item)

let isFetchingInitialData = ref(false)

itemStore.$reset()
loadData()

const price = computed({
  get: () => itemStore.currentItem.price / 100,
  set: (value) => {
    itemStore.currentItem.price = Math.round(value * 100)
  },
})

const taxes = computed({
  get: () =>
    itemStore?.currentItem?.taxes?.map((tax) => {
      if (tax) {
        return {
          ...tax,
          tax_type_id: tax.id,
          tax_name: tax.name + ' (' + tax.percent + '%)',
        }
      }
    }),
  set: (value) => {
    itemStore.currentItem.taxes = value
  },
})

const isEdit = computed(() => route.name === 'items.edit')

const pageTitle = computed(() =>
  isEdit.value ? t('items.edit_item') : t('items.new_item')
)

const getTaxTypes = computed(() => {
  return taxTypeStore.taxTypes.map((tax) => {
    return {
      ...tax,
      tax_type_id: tax.id,
      tax_name: tax.name + ' (' + tax.percent + '%)',
    }
  })
})

const isTaxPerItem = computed(() => taxPerItem.value === 'YES')

const rules = computed(() => {
  return {
    currentItem: {
      name: {
        required: helpers.withMessage(t('validation.required'), required),
        minLength: helpers.withMessage(
          t('validation.name_min_length', { count: 3 }),
          minLength(3)
        ),
      },

      description: {
        maxLength: helpers.withMessage(
          t('validation.description_maxlength'),
          maxLength(65000)
        ),
      },
    },
  }
})

const v$ = useVuelidate(rules, itemStore)

async function addItemUnit() {
  modalStore.openModal({
    title: t('settings.customization.items.add_item_unit'),
    componentName: 'ItemUnitModal',
    size: 'sm',
  })
}

async function loadData() {
  isFetchingInitialData.value = true

  await itemStore.fetchItemUnits({ limit: 'all' })
  if (userStore.hasAbilities(abilities.VIEW_TAX_TYPE)) {
    await taxTypeStore.fetchTaxTypes({ limit: 'all' })
  }

  if (isEdit.value) {
    let id = route.params.id
    await itemStore.fetchItem(id)
    itemStore.currentItem.tax_per_item === 1
      ? (taxPerItem.value = 'YES')
      : (taxPerItem.value = 'NO')
  }

  isFetchingInitialData.value = false
}

async function submitItem() {
  v$.value.currentItem.$touch()

  if (v$.value.currentItem.$invalid) {
    return false
  }

  isSaving.value = true

  try {
    let data = {
      id: route.params.id,
      ...itemStore.currentItem,
    }

    if (itemStore.currentItem && itemStore.currentItem.taxes) {
      data.taxes = itemStore.currentItem.taxes.map((tax) => {
        return {
          tax_type_id: tax.tax_type_id,
          amount: price.value * tax.percent,
          percent: tax.percent,
          name: tax.name,
          collective_tax: 0,
        }
      })
    }

    const action = isEdit.value ? itemStore.updateItem : itemStore.addItem

    await action(data)
    isSaving.value = false
    router.push('/admin/items')
    closeItemModal()
  } catch (err) {
    isSaving.value = false
    return
  }
  function closeItemModal() {
    modalStore.closeModal()
    setTimeout(() => {
      itemStore.resetCurrentItem()
      modalStore.$reset()
      v$.value.$reset()
    }, 300)
  }
}
</script>
