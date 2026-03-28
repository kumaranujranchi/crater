<template>
  <!-- Trigger button -->
  <button
    type="button"
    class="flex items-center gap-1.5 text-xs text-gray-500 hover:text-primary-500 transition mt-1"
    @click="openManager"
  >
    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
    </svg>
    Manage Custom Fields
  </button>

  <!-- Modal -->
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-60"
    @click.self="close"
  >
    <div class="bg-white rounded-xl shadow-2xl p-6 w-full max-w-md mx-4 max-h-screen overflow-y-auto">
      <div class="flex justify-between items-center mb-5">
        <h3 class="text-base font-bold text-gray-800">Custom Fields</h3>
        <button type="button" class="text-gray-400 hover:text-gray-600" @click="close">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>

      <p class="text-xs text-gray-500 mb-4">
        Yahan apne custom fields define karo (jaise MFG Date, Expiry Date, HSN Code etc.)
        Ye fields har new item form mein dikhenge.
      </p>

      <!-- Existing templates -->
      <div v-if="templates.length > 0" class="space-y-2 mb-4">
        <div
          v-for="(tpl, idx) in templates"
          :key="idx"
          class="flex items-center gap-2 bg-gray-50 rounded-lg px-3 py-2"
        >
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-gray-700 truncate">{{ tpl.label }}</p>
            <p class="text-xs text-gray-400">{{ typeLabel(tpl.type) }}</p>
          </div>
          <button
            type="button"
            class="text-red-400 hover:text-red-600 flex-shrink-0"
            @click="removeTemplate(idx)"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>
      <p v-else class="text-sm text-gray-400 text-center py-3 mb-4">Abhi koi custom field nahi hai</p>

      <!-- Add new field form -->
      <div class="border-t pt-4">
        <p class="text-xs font-semibold text-gray-600 mb-3 uppercase tracking-wide">Naya Field Add Karo</p>
        <div class="space-y-3">
          <div>
            <label class="block text-xs text-gray-600 mb-1">Field Label <span class="text-red-500">*</span></label>
            <input
              v-model="newField.label"
              type="text"
              placeholder="jaise: MFG Date, HSN Code"
              class="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-300"
            />
          </div>
          <div>
            <label class="block text-xs text-gray-600 mb-1">Field Type</label>
            <select
              v-model="newField.type"
              class="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-300"
            >
              <option value="text">Text</option>
              <option value="number">Number</option>
              <option value="date">Date</option>
              <option value="textarea">Long Text</option>
            </select>
          </div>
          <p v-if="addError" class="text-xs text-red-500">{{ addError }}</p>
          <button
            type="button"
            class="w-full bg-primary-500 hover:bg-primary-600 text-white font-medium text-sm py-2 rounded-md transition"
            @click="addTemplate"
          >
            + Add Field
          </button>
        </div>
      </div>

      <!-- Done -->
      <button
        type="button"
        class="mt-4 w-full border border-gray-300 text-gray-600 hover:bg-gray-50 font-medium text-sm py-2 rounded-md transition"
        @click="close"
      >
        Done
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const STORAGE_KEY = 'synergy_item_custom_field_templates'

const isOpen = ref(false)
const templates = ref([])
const addError = ref('')
const newField = ref({ label: '', type: 'text' })

onMounted(() => {
  loadTemplates()
})

function loadTemplates() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    templates.value = saved ? JSON.parse(saved) : []
  } catch {
    templates.value = []
  }
}

function saveTemplates() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(templates.value))
}

function typeLabel(type) {
  const map = { text: 'Text', number: 'Number', date: 'Date', textarea: 'Long Text' }
  return map[type] || type
}

function openManager() {
  loadTemplates()
  isOpen.value = true
}

function addTemplate() {
  addError.value = ''
  const label = newField.value.label.trim()
  if (!label) {
    addError.value = 'Field label required hai'
    return
  }
  // Generate key from label
  const key = label.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '')
  if (templates.value.find((t) => t.key === key)) {
    addError.value = 'Iss naam ka field already exists'
    return
  }
  templates.value.push({ key, label, type: newField.value.type })
  saveTemplates()
  newField.value = { label: '', type: 'text' }
}

function removeTemplate(idx) {
  templates.value.splice(idx, 1)
  saveTemplates()
}

function close() {
  isOpen.value = false
  // Notify parent that templates may have changed
  window.dispatchEvent(new Event('storage'))
}

// Expose method to get templates (used by parent)
defineExpose({ loadTemplates, getTemplates: () => templates.value })
</script>
