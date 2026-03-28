<template>
  <svg viewBox="0 0 420 50" fill="none" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <linearGradient id="logoGrad" x1="0" y1="0" x2="420" y2="0" gradientUnits="userSpaceOnUse">
        <stop :stop-color="darkColor" />
        <stop offset="1" :stop-color="lightColor" />
      </linearGradient>
    </defs>
    <text
      x="0"
      y="38"
      font-family="Arial, sans-serif"
      font-size="34"
      font-weight="bold"
      letter-spacing="1"
      fill="url(#logoGrad)"
    >SynergyBilling Pro</text>
  </svg>
</template>

<script setup>
defineProps({
  darkColor: {
    type: String,
    default: 'rgba(var(--color-primary-500), var(--tw-text-opacity))',
  },
  lightColor: {
    type: String,
    default: 'rgba(var(--color-primary-400), var(--tw-text-opacity))',
  },
})
</script>
