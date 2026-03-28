<template>
  <!-- Barcode Scanner Modal -->
  <BarcodeScanner ref="scannerRef" hide-button @scanned="onBarcodeScanned" />

  <!-- Mobile section label -->
  <div class="lg:hidden flex items-center justify-between px-4 pt-4 pb-2">
    <p class="text-sm font-semibold text-gray-700 uppercase tracking-wide">{{ $tc('items.item', 2) }}</p>
    <button
      type="button"
      class="flex items-center gap-1.5 text-sm font-medium text-primary-500"
      @click="openBarcodeScanner"
    >
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m0 14v1M4 12H3m18 0h-1M6.343 6.343l-.707-.707m12.728 12.728l-.707-.707M6.343 17.657l-.707.707M17.657 6.343l-.707.707M12 8a4 4 0 100 8 4 4 0 000-8z" />
      </svg>
      Scan
    </button>
  </div>

  <!-- Items table (mobile: block/card, desktop: table) -->
  <table class="text-center item-table w-full">
    <colgroup class="hidden lg:table-column-group">
      <col style="width: 40%; min-width: 280px" />
      <col style="width: 10%; min-width: 120px" />
      <col style="width: 15%; min-width: 120px" />
      <col
        v-if="store[storeProp].discount_per_item === 'YES'"
        style="width: 15%; min-width: 160px"
      />
      <col style="width: 15%; min-width: 120px" />
    </colgroup>
    <thead class="hidden lg:table-header-group bg-white border border-gray-200 border-solid">
      <tr>
        <th class="px-5 py-3 text-sm not-italic font-medium leading-5 text-left text-gray-700 border-t border-b border-gray-200 border-solid">
          <BaseContentPlaceholders v-if="isLoading">
            <BaseContentPlaceholdersText :lines="1" class="w-16 h-5" />
          </BaseContentPlaceholders>
          <span v-else class="pl-7">{{ $tc('items.item', 2) }}</span>
        </th>
        <th class="px-5 py-3 text-sm not-italic font-medium leading-5 text-right text-gray-700 border-t border-b border-gray-200 border-solid">
          <BaseContentPlaceholders v-if="isLoading">
            <BaseContentPlaceholdersText :lines="1" class="w-16 h-5" />
          </BaseContentPlaceholders>
          <span v-else>{{ $t('invoices.item.quantity') }}</span>
        </th>
        <th class="px-5 py-3 text-sm not-italic font-medium leading-5 text-left text-gray-700 border-t border-b border-gray-200 border-solid">
          <BaseContentPlaceholders v-if="isLoading">
            <BaseContentPlaceholdersText :lines="1" class="w-16 h-5" />
          </BaseContentPlaceholders>
          <span v-else>{{ $t('invoices.item.price') }}</span>
        </th>
        <th
          v-if="store[storeProp].discount_per_item === 'YES'"
          class="px-5 py-3 text-sm not-italic font-medium leading-5 text-left text-gray-700 border-t border-b border-gray-200 border-solid"
        >
          <BaseContentPlaceholders v-if="isLoading">
            <BaseContentPlaceholdersText :lines="1" class="w-16 h-5" />
          </BaseContentPlaceholders>
          <span v-else>{{ $t('invoices.item.discount') }}</span>
        </th>
        <th class="px-5 py-3 text-sm not-italic font-medium leading-5 text-right text-gray-700 border-t border-b border-gray-200 border-solid">
          <BaseContentPlaceholders v-if="isLoading">
            <BaseContentPlaceholdersText :lines="1" class="w-16 h-5" />
          </BaseContentPlaceholders>
          <span v-else class="pr-10 column-heading">{{ $t('invoices.item.amount') }}</span>
        </th>
      </tr>
    </thead>
    <draggable
      v-model="store[storeProp].items"
      item-key="id"
      tag="tbody"
      handle=".handle"
    >
      <template #item="{ element, index }">
        <Item
          :key="element.id"
          :index="index"
          :item-data="element"
          :loading="isLoading"
          :currency="defaultCurrency"
          :item-validation-scope="itemValidationScope"
          :invoice-items="store[storeProp].items"
          :store="store"
          :store-prop="storeProp"
        />
      </template>
    </draggable>
  </table>

  <!-- Add Item / Scan row -->
  <div class="flex items-center border border-t-0 border-gray-200 border-solid rounded-b-lg overflow-hidden">
    <!-- Add manually -->
    <div
      class="flex flex-1 items-center justify-center px-4 py-3 text-sm cursor-pointer text-primary-400 hover:bg-primary-50 transition font-medium"
      @click="store.addItem"
    >
      <BaseIcon name="PlusCircleIcon" class="mr-2 h-5 w-5" />
      {{ $t('general.add_new_item') }}
    </div>

    <!-- Divider -->
    <div class="w-px h-10 bg-gray-200 flex-shrink-0" />

    <!-- Scan barcode -->
    <button
      type="button"
      class="flex items-center gap-2 px-4 py-3 text-sm font-medium text-primary-500 hover:bg-primary-50 transition whitespace-nowrap"
      @click="openBarcodeScanner"
    >
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m0 14v1M4 12H3m18 0h-1M6.343 6.343l-.707-.707m12.728 12.728l-.707-.707M6.343 17.657l-.707.707M17.657 6.343l-.707.707M12 8a4 4 0 100 8 4 4 0 000-8z" />
      </svg>
      Scan
    </button>
  </div>

  <!-- Scan status -->
  <div v-if="scanStatus" class="flex items-center gap-2 px-4 py-2 text-xs rounded-b-md"
    :class="{
      'bg-yellow-50 text-yellow-700': scanStatus === 'loading',
      'bg-green-50 text-green-700': scanStatus === 'found',
      'bg-gray-50 text-gray-500': scanStatus === 'not_found',
    }"
  >
    <svg v-if="scanStatus === 'loading'" class="h-3.5 w-3.5 animate-spin" viewBox="0 0 24 24" fill="none">
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
    </svg>
    <svg v-else-if="scanStatus === 'found'" class="h-3.5 w-3.5" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
    </svg>
    <svg v-else class="h-3.5 w-3.5" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
    </svg>
    {{ scanMessage }}
  </div>
</template>

<script setup>
import { useCompanyStore } from '@/scripts/admin/stores/company'
import { useItemStore } from '@/scripts/admin/stores/item'
import { computed, ref } from 'vue'
import Guid from 'guid'
import draggable from 'vuedraggable'
import Item from './CreateItemRow.vue'
import BarcodeScanner from '@/scripts/admin/components/BarcodeScanner.vue'

const props = defineProps({
  store: {
    type: Object,
    default: null,
  },
  storeProp: {
    type: String,
    default: '',
  },
  currency: {
    type: [Object, String, null],
    required: true,
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
  itemValidationScope: {
    type: String,
    default: '',
  },
})

const companyStore = useCompanyStore()
const itemStore = useItemStore()

const scannerRef = ref(null)
const scanStatus = ref('')
const scanMessage = ref('')

const defaultCurrency = computed(() => {
  if (props.currency) {
    return props.currency
  } else {
    return companyStore.selectedCompanyCurrency
  }
})

function openBarcodeScanner() {
  scannerRef.value?.openScanner()
}

async function onBarcodeScanned({ raw, parsed }) {
  scanStatus.value = 'loading'
  scanMessage.value = 'Product dhoondh rahe hain...'

  // Case 1: structured QR JSON
  if (parsed && parsed.name) {
    addLineItem(parsed.name, parsed.description || '', parsed.price ? Math.round(parsed.price * 100) : 0, parsed.item_id || null)
    scanStatus.value = 'found'
    scanMessage.value = `"${parsed.name}" invoice mein add ho gayi`
    return
  }

  // Case 2: search local Crater DB
  try {
    await itemStore.fetchItems({ search: raw, limit: 10 })
    const exact = itemStore.items.find((i) => i.name === raw)
    const partial = itemStore.items[0]
    const match = exact || partial
    if (match && (exact || match.name.toLowerCase().includes(raw.toLowerCase()) || raw.toLowerCase().includes(match.name.toLowerCase()))) {
      addLineItem(match.name, match.description || '', match.price, match.id)
      scanStatus.value = 'found'
      scanMessage.value = `"${match.name}" — aapke catalog se add ho gayi`
      return
    }
  } catch (_) {}

  // Case 3: Open Food Facts API
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
        const desc = [p.brands, p.quantity].filter(Boolean).join(' — ')
        addLineItem(name, desc, 0, null)
        scanStatus.value = 'found'
        scanMessage.value = `"${name}" add ho gayi — price bharo`
        return
      }
    }
  } catch (_) {}

  // Not found — add blank row with barcode as name
  addLineItem(raw, '', 0, null)
  scanStatus.value = 'not_found'
  scanMessage.value = `Barcode ${raw} — details nahi mili, price manually bharo`
}

function addLineItem(name, description, price, itemId) {
  props.store[props.storeProp].items.push({
    id: Guid.raw(),
    item_id: itemId,
    name: name,
    title: name,
    description: description,
    quantity: 1,
    price: price,
    discount_type: 'fixed',
    discount_val: 0,
    discount: 0,
    total: price,
    totalTax: 0,
    totalSimpleTax: 0,
    totalCompoundTax: 0,
    tax: 0,
    taxes: [],
  })
  // Auto-clear status after 4 seconds
  setTimeout(() => { scanStatus.value = '' }, 4000)
}
</script>

<style scoped>
@media (max-width: 1023px) {
  table.item-table,
  table.item-table > tbody {
    display: block;
    width: 100%;
  }
  table.item-table tbody tr,
  table.item-table tbody td {
    display: block;
    width: 100%;
  }
}
</style>
