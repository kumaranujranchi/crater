<template>
  <div>
    <!-- Scan Button -->
    <button
      type="button"
      class="flex items-center gap-2 px-3 py-2 text-sm font-medium text-primary-500 border border-primary-400 rounded-md hover:bg-primary-50 transition"
      @click="openScanner"
    >
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m0 14v1M4 12H3m18 0h-1M6.343 6.343l-.707-.707m12.728 12.728l-.707-.707M6.343 17.657l-.707.707M17.657 6.343l-.707.707M12 8a4 4 0 100 8 4 4 0 000-8z" />
      </svg>
      Scan Barcode
    </button>

    <!-- Scanner Modal -->
    <div
      v-if="isOpen"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70"
      @click.self="closeScanner"
    >
      <div class="bg-white rounded-xl shadow-xl p-5 w-full max-w-sm mx-4">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-base font-semibold text-gray-800">Scan Barcode</h3>
          <button type="button" class="text-gray-400 hover:text-gray-600" @click="closeScanner">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>

        <div class="relative rounded-lg overflow-hidden bg-black" style="aspect-ratio: 4/3;">
          <video ref="videoEl" class="w-full h-full object-cover" />
          <!-- Scan line animation -->
          <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
            <div class="w-4/5 h-0.5 bg-red-500 opacity-75 animate-pulse" />
          </div>
        </div>

        <p v-if="errorMsg" class="mt-3 text-sm text-red-500 text-center">{{ errorMsg }}</p>
        <p class="mt-3 text-xs text-gray-400 text-center">Camera ke saamne barcode/QR code rakho</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { BrowserMultiFormatReader } from '@zxing/browser'

const emit = defineEmits(['scanned'])

const isOpen = ref(false)
const videoEl = ref(null)
const errorMsg = ref('')
let codeReader = null
let controls = null

async function openScanner() {
  isOpen.value = true
  errorMsg.value = ''
}

watch(isOpen, async (val) => {
  if (val) {
    // Wait for DOM
    await new Promise((r) => setTimeout(r, 100))
    startScan()
  }
})

async function startScan() {
  try {
    codeReader = new BrowserMultiFormatReader()
    controls = await codeReader.decodeFromVideoDevice(undefined, videoEl.value, (result, err) => {
      if (result) {
        emit('scanned', result.getText())
        closeScanner()
      }
    })
  } catch (e) {
    errorMsg.value = 'Camera access nahi mila. Browser me camera allow karo.'
  }
}

function closeScanner() {
  if (controls) {
    controls.stop()
    controls = null
  }
  isOpen.value = false
}
</script>
