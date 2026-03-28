<template>
  <div class="md:hidden fixed bottom-0 left-0 z-40 w-full pointer-events-none pb-safe">
    <!-- SVG Background for the cutout -->
    <div class="absolute bottom-0 left-0 w-full h-[72px] pointer-events-auto">
      <svg class="w-full h-full drop-shadow-[0_-5px_10px_rgba(0,0,0,0.05)]" viewBox="0 0 400 72" preserveAspectRatio="none" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M0 12C0 5.37258 5.37258 0 12 0H155.5C161.464 0 166.762 3.51866 169.176 9.01509C173.818 19.5849 185.341 27 199 27C212.659 27 224.182 19.5849 228.824 9.01509C231.238 3.51866 236.536 0 242.5 0H388C394.627 0 400 5.37258 400 12V72H0V12Z" fill="white"/>
      </svg>
    </div>

    <!-- Navigation Content -->
    <div class="relative flex items-center justify-between px-2 h-16 pointer-events-auto">
      <router-link
        to="/admin/dashboard"
        class="flex flex-col items-center justify-center flex-1 h-full text-gray-400"
        active-class="!text-primary-500 font-bold"
      >
        <BaseIcon name="ChartBarIcon" class="w-6 h-6" />
        <span class="text-[9px] font-medium tracking-tight mt-0.5">{{ $t('navigation.dashboard') }}</span>
      </router-link>

      <router-link
        to="/admin/invoices"
        class="flex flex-col items-center justify-center flex-1 h-full text-gray-400"
        active-class="!text-primary-500 font-bold"
      >
        <BaseIcon name="DocumentTextIcon" class="w-6 h-6" />
        <span class="text-[9px] font-medium tracking-tight mt-0.5">{{ $t('navigation.invoices') }}</span>
      </router-link>

      <!-- Central Gap for FAB -->
      <div class="w-16 flex-shrink-0"></div>

      <router-link
        to="/admin/customers"
        class="flex flex-col items-center justify-center flex-1 h-full text-gray-400"
        active-class="!text-primary-500 font-bold"
      >
        <BaseIcon name="UserIcon" class="w-6 h-6" />
        <span class="text-[9px] font-medium tracking-tight mt-0.5">{{ $t('navigation.customers') }}</span>
      </router-link>

      <div
        class="flex flex-col items-center justify-center flex-1 h-full text-gray-400 cursor-pointer"
        @click="globalStore.setSidebarVisibility(true)"
      >
        <BaseIcon name="MenuIcon" class="w-6 h-6" />
        <span class="text-[9px] font-medium tracking-tight mt-0.5">{{ $t('navigation.menu') }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useGlobalStore } from '@/scripts/admin/stores/global'
const globalStore = useGlobalStore()
</script>

<style scoped>
.pb-safe {
    padding-bottom: env(safe-area-inset-bottom);
}
</style>
