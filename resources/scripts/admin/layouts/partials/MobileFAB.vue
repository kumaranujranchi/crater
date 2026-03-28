<template>
  <div class="md:hidden fixed bottom-0 left-1/2 transform -translate-x-1/2 z-50 pointer-events-none pb-safe">
    <!-- Main FAB Container -->
    <div class="relative mb-6 pointer-events-auto">
      <button
        :class="{ 'rotate-45 bg-red-500': isOpen }"
        class="w-14 h-14 bg-primary-600 rounded-full shadow-fab flex items-center justify-center text-white focus:outline-none transition-all duration-300 border-4 border-white"
        @click="toggleMenu"
      >
        <BaseIcon name="PlusIcon" class="w-7 h-7" />
      </button>

      <!-- Action Menu -->
      <transition name="fade-scale">
        <div
          v-if="isOpen"
          class="absolute bottom-20 left-1/2 transform -translate-x-1/2 bg-white rounded-2xl shadow-2xl border border-gray-100 p-2 w-52 origin-bottom"
        >
          <router-link
            to="/admin/invoices/create"
            class="flex items-center px-4 py-3 text-sm text-gray-700 hover:bg-primary-50 hover:text-primary-600 rounded-xl transition-colors"
            @click="isOpen = false"
          >
            <div class="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center mr-3">
              <BaseIcon name="DocumentTextIcon" class="w-5 h-5 text-primary-600" />
            </div>
            <span class="font-medium">{{ $t('invoices.new_invoice') }}</span>
          </router-link>
          
          <router-link
            to="/admin/customers/create"
            class="flex items-center px-4 py-3 text-sm text-gray-700 hover:bg-primary-50 hover:text-primary-600 rounded-xl transition-colors mt-1"
            @click="isOpen = false"
          >
            <div class="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center mr-3">
              <BaseIcon name="UserIcon" class="w-5 h-5 text-primary-600" />
            </div>
            <span class="font-medium">{{ $t('customers.new_customer') }}</span>
          </router-link>

          <router-link
            to="/admin/estimates/create"
            class="flex items-center px-4 py-3 text-sm text-gray-700 hover:bg-primary-50 hover:text-primary-600 rounded-xl transition-colors mt-1"
            @click="isOpen = false"
          >
            <div class="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center mr-3">
              <BaseIcon name="DocumentIcon" class="w-5 h-5 text-primary-600" />
            </div>
            <span class="font-medium">{{ $t('estimates.new_estimate') }}</span>
          </router-link>
        </div>
      </transition>
    </div>
    
    <!-- Backdrop -->
    <div 
      v-if="isOpen" 
      class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm -z-10 pointer-events-auto"
      @click="isOpen = false"
    ></div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const isOpen = ref(false)

function toggleMenu() {
  isOpen.value = !isOpen.value
}
</script>

<style scoped>
.shadow-fab {
  box-shadow: 0 10px 25px -5px rgba(88, 81, 216, 0.5), 0 8px 10px -6px rgba(88, 81, 216, 0.5);
}
.pb-safe {
    padding-bottom: env(safe-area-inset-bottom);
}
.fade-scale-enter-active, .fade-scale-leave-active {
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.fade-scale-enter-from, .fade-scale-leave-to {
  opacity: 0;
  transform: translate(-50%, 20px) scale(0.8);
}
</style>
