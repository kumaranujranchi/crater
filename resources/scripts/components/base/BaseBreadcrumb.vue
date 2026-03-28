<template>
  <nav class="hidden md:flex">
    <ol class="flex flex-wrap py-4 text-gray-900 rounded list-reset">
      <slot />
    </ol>
  </nav>
</template>

<script>
export default {
  name: 'BaseBreadcrumb',
}
</script>
