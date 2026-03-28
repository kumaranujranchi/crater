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
            <!-- Lookup status -->
            <div v-if="lookupStatus" class="mt-2 flex items-center gap-2 text-xs rounded-md px-3 py-2"
              :class="{
                'bg-yellow-50 text-yellow-700': lookupStatus === 'loading',
                'bg-green-50 text-green-700': lookupStatus === 'found',
                'bg-gray-50 text-gray-500': lookupStatus === 'not_found',
                'bg-red-50 text-red-600': lookupStatus === 'error',
              }"
            >
              <svg v-if="lookupStatus === 'loading'" class="h-3.5 w-3.5 animate-spin" viewBox="0 0 24 24" fill="none">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
              </svg>
              <svg v-else-if="lookupStatus === 'found'" class="h-3.5 w-3.5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
              </svg>
              <svg v-else class="h-3.5 w-3.5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
              </svg>
              {{ lookupMessage }}
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
const lookupStatus = ref('') // 'loading' | 'found' | 'not_found' | 'error' | ''
const lookupMessage = ref('')

function loadFieldTemplates() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    customFieldTemplates.value = saved ? JSON.parse(saved) : []
  } catch {
    customFieldTemplates.value = []
  }
  const existing = itemStore.currentItem.custom_fields || []
  itemStore.currentItem.custom_fields = customFieldTemplates.value.map((tpl) => {
    const found = existing.find((f) => f.key === tpl.key)
    return { key: tpl.key, label: tpl.label, type: tpl.type, value: found ? found.value : '' }
  })
}

onMounted(() => {
  loadFieldTemplates()
  window.addEventListener('storage', loadFieldTemplates)
})

function applyItemData(name, description, priceInPaise) {
  if (name) itemStore.currentItem.name = name
  if (description) itemStore.currentItem.description = description
  if (priceInPaise) itemStore.currentItem.price = priceInPaise
  v$.value.currentItem.name.$touch()
}

async function onBarcodeScanned({ raw, parsed }) {
  // Case 1: QR code with embedded JSON — use directly
  if (parsed) {
    applyItemData(
      parsed.name,
      parsed.description || parsed.brand || '',
      parsed.price ? Math.round(parsed.price * 100) : null
    )
    // Auto-fill custom fields too
    itemStore.currentItem.custom_fields = itemStore.currentItem.custom_fields.map((field) =>
      parsed[field.key] !== undefined ? { ...field, value: String(parsed[field.key]) } : field
    )
    lookupStatus.value = 'found'
    lookupMessage.value = 'Barcode se details mil gayi'
    return
  }

  // Plain barcode number — put it in name first so form isn't empty
  itemStore.currentItem.name = raw
  v$.value.currentItem.name.$touch()

  // Case 2: Search in Crater's own item database first
  lookupStatus.value = 'loading'
  lookupMessage.value = 'Product details dhoondh rahe hain...'
  try {
    const localRes = await itemStore.fetchItems({ search: raw, limit: 5 })
    const match = itemStore.items.find(
      (i) => i.name === raw || (i.description && i.description.includes(raw))
    )
    if (match) {
      applyItemData(match.name, match.description, match.price)
      lookupStatus.value = 'found'
      lookupMessage.value = `"${match.name}" — aapke database se mili`
      return
    }
  } catch (_) {}

  // Case 3: Open Food Facts free API (works for EAN-8 / EAN-13 / UPC barcodes)
  try {
    const res = await fetch(
      `https://world.openfoodfacts.org/api/v0/product/${encodeURIComponent(raw)}.json`,
      { signal: AbortSignal.timeout(8000) }
    )
    if (res.ok) {
      const data = await res.json()
      if (data.status === 1 && data.product) {
        const p = data.product
        const name = p.product_name || p.product_name_en || raw
        const brand = p.brands || ''
        const qty = p.quantity || ''
        const desc = [brand, qty].filter(Boolean).join(' — ')
        applyItemData(name, desc, null)
        lookupStatus.value = 'found'
        lookupMessage.value = `"${name}" — Open Food Facts se mili`
        return
      }
    }
  } catch (_) {}

  // Nothing found
  lookupStatus.value = 'not_found'
  lookupMessage.value = `Barcode ${raw} — koi details nahi mili. Manually bharo.`
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
