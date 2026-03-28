<template>
  <BaseModal
    :show="modalActive"
    @close="closeModal"
  >
    <template #header>
      <div class="flex justify-between w-full">
        {{ $t('invoices.print_invoice') }}
        <BaseIcon
          name="XIcon"
          class="w-6 h-6 text-gray-500 cursor-pointer"
          @click="closeModal"
        />
      </div>
    </template>

    <div class="p-8 space-y-6">
      <p class="text-gray-600 text-sm">
        Choose your printer type. The layout will automatically adjust for the best quality.
      </p>
      
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <!-- Standard A4 Button -->
        <button 
          class="flex flex-col items-center justify-center p-6 border-2 border-gray-100 rounded-2xl hover:border-primary-500 hover:bg-primary-50 transition-all group"
          @click="printStandard"
        >
          <div class="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mb-4 group-hover:bg-primary-200">
            <BaseIcon name="PrinterIcon" class="w-8 h-8 text-primary-600" />
          </div>
          <span class="font-bold text-gray-900 leading-tight">Standard Print</span>
          <span class="text-xs text-gray-500 mt-1">A4 / Letter Size</span>
        </button>

        <!-- Thermal Button -->
        <button 
          class="flex flex-col items-center justify-center p-6 border-2 border-gray-100 rounded-2xl hover:border-primary-500 hover:bg-primary-50 transition-all group"
          @click="printThermal"
        >
          <div class="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mb-4 group-hover:bg-orange-200">
            <BaseIcon name="DocumentTextIcon" class="w-8 h-8 text-orange-600" />
          </div>
          <span class="font-bold text-gray-900 leading-tight">Thermal Receipt</span>
          <span class="text-xs text-gray-500 mt-1">58mm / 80mm POS</span>
        </button>
      </div>
    </div>

    <!-- Hidden Thermal Receipt for Printing -->
    <div v-if="invoiceData" id="thermal-receipt-printable" class="hidden-print thermal-layout">
      <div class="receipt-container">
        <center>
          <h2 class="company-name">{{ invoiceData.company.name }}</h2>
          <p class="company-info">{{ invoiceData.company.address }}</p>
          <p class="company-info">Phone: {{ invoiceData.company.phone }}</p>
          <hr/>
          <h3 class="receipt-title">INVOICE</h3>
          <p>#{{ invoiceData.invoice_number }} | {{ invoiceData.formatted_invoice_date }}</p>
          <hr/>
        </center>
        
        <p><strong>To:</strong> {{ invoiceData.customer.name }}</p>
        
        <table class="receipt-table">
          <thead>
            <tr>
              <th align="left">Item</th>
              <th align="center">Qty</th>
              <th align="right">Total</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in invoiceData.items" :key="item.id">
              <td>{{ item.name }}</td>
              <td align="center">{{ item.quantity }}</td>
              <td align="right">{{ item.total }}</td>
            </tr>
          </tbody>
        </table>
        
        <hr/>
        <div class="summary">
          <div class="summary-line">
            <span>Subtotal:</span>
            <span>{{ invoiceData.sub_total }}</span>
          </div>
          <div class="summary-line font-bold">
            <span>TOTAL:</span>
            <span>{{ invoiceData.total }}</span>
          </div>
        </div>
        
        <center class="footer">
          <p>Thank you for your business!</p>
          <p>{{ invoiceData.company.website }}</p>
        </center>
      </div>
    </div>
  </BaseModal>
</template>

<script setup>
import { computed, nextTick } from 'vue'
import { useModalStore } from '@/scripts/stores/modal'

const modalStore = useModalStore()

const modalActive = computed(() => {
  return modalStore.active && modalStore.componentName === 'PrintInvoiceModal'
})

const invoiceData = computed(() => {
  return modalStore.data
})

function closeModal() {
  modalStore.closeModal()
}

function printStandard() {
  const printUrl = `/invoices/pdf/${invoiceData.value.unique_hash}`
  window.open(printUrl, '_blank')
}

async function printThermal() {
  // We use a CSS class to switch styles for printing
  document.body.classList.add('is-printing-thermal')
  
  await nextTick()
  window.print()
  
  // Cleanup after print dialog closes
  setTimeout(() => {
    document.body.classList.remove('is-printing-thermal')
  }, 500)
}
</script>

<style scoped>
/* Hidden by default in UI but visible in ID search */
.hidden-print {
  display: none;
}

/* Base Thermal Styles */
.thermal-layout {
  font-family: 'Courier New', Courier, monospace;
  width: 58mm;
  padding: 5mm;
  background: white;
  color: black;
}

.receipt-container hr {
  border: none;
  border-top: 1px dashed #000;
  margin: 5px 0;
}

.company-name { font-size: 16px; margin: 0; }
.company-info { font-size: 10px; margin: 2px 0; }
.receipt-title { font-size: 14px; margin: 5px 0; }

.receipt-table {
  width: 100%;
  font-size: 11px;
  border-collapse: collapse;
  margin: 10px 0;
}

.receipt-table th {
  border-bottom: 1px solid #000;
  padding: 4px 0;
}

.summary {
  font-size: 11px;
}

.summary-line {
  display: flex;
  justify-content: space-between;
  margin: 2px 0;
}

.footer {
  margin-top: 20px;
  font-size: 10px;
}

/* Print specific styles */
@media print {
  body.is-printing-thermal > *:not(#thermal-receipt-printable) {
    display: none !important;
  }
  
  body.is-printing-thermal #thermal-receipt-printable {
    display: block !important;
    position: absolute;
    left: 0;
    top: 0;
    width: 58mm; /* Adjust for thermal printer */
  }

  @page {
    margin: 0;
  }
}
</style>
