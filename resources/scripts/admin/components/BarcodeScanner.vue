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
          <video ref="videoEl" class="w-full h-full object-cover" autoplay playsinline muted />
          <!-- Corner guides -->
          <div class="absolute inset-0 pointer-events-none">
            <div class="absolute top-4 left-4 w-8 h-8 border-t-4 border-l-4 border-green-400 rounded-tl" />
            <div class="absolute top-4 right-4 w-8 h-8 border-t-4 border-r-4 border-green-400 rounded-tr" />
            <div class="absolute bottom-4 left-4 w-8 h-8 border-b-4 border-l-4 border-green-400 rounded-bl" />
            <div class="absolute bottom-4 right-4 w-8 h-8 border-b-4 border-r-4 border-green-400 rounded-br" />
            <!-- Scanning line -->
            <div v-if="scanning" class="absolute left-4 right-4 h-0.5 bg-red-500 scan-line" />
          </div>
        </div>

        <p v-if="errorMsg" class="mt-3 text-sm text-red-500 text-center">{{ errorMsg }}</p>
        <p v-else-if="scanning" class="mt-3 text-xs text-green-600 text-center font-medium animate-pulse">Scanning... barcode/QR saamne rakho</p>
        <p v-else class="mt-3 text-xs text-gray-400 text-center">Camera shuru ho raha hai...</p>
        <button
          v-if="errorMsg"
          type="button"
          class="mt-2 w-full text-sm text-primary-500 hover:underline"
          @click="startScan"
        >Try Again</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue'
import { BrowserMultiFormatReader } from '@zxing/browser'

const emit = defineEmits(['scanned'])

const isOpen = ref(false)
const videoEl = ref(null)
const errorMsg = ref('')
const scanning = ref(false)
let controls = null

async function openScanner() {
  errorMsg.value = ''
  scanning.value = false
  isOpen.value = true
}

// flush:'post' ensures watcher runs after DOM update so videoEl ref is ready
watch(isOpen, async (val) => {
  if (val) {
    await nextTick()
    startScan()
  }
}, { flush: 'post' })

async function startScan() {
  errorMsg.value = ''
  scanning.value = false
  if (controls) {
    controls.stop()
    controls = null
  }
  try {
    const codeReader = new BrowserMultiFormatReader()
    controls = await codeReader.decodeFromConstraints(
      {
        video: {
          facingMode: { ideal: 'environment' }, // back camera on mobile
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
      },
      videoEl.value,
      (result, err) => {
        if (result) {
          const text = result.getText()
          let parsed = null
          try {
            const obj = JSON.parse(text)
            if (typeof obj === 'object' && obj !== null) {
              parsed = obj
            }
          } catch {
            // plain barcode string
          }
          emit('scanned', { raw: text, parsed })
          closeScanner()
        }
        // NotFoundException fires every frame when no barcode in view — ignore
      }
    )
    scanning.value = true
  } catch (e) {
    errorMsg.value =
      e.name === 'NotAllowedError'
        ? 'Camera permission deny hai. Browser settings mein allow karo.'
        : e.name === 'NotFoundError'
        ? 'Koi camera nahi mila device pe.'
        : 'Camera shuru nahi hua: ' + (e.message || e.name)
  }
}

function closeScanner() {
  if (controls) {
    controls.stop()
    controls = null
  }
  scanning.value = false
  isOpen.value = false
}
</script>

<style scoped>
.scan-line {
  top: 50%;
  animation: scan 2s linear infinite;
}
@keyframes scan {
  0%   { top: 15%; }
  50%  { top: 85%; }
  100% { top: 15%; }
}
</style>
