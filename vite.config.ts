import { defineConfig } from 'laravel-vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
    build: {
        rollupOptions: {
            input: 'resources/scripts/main.js'
        }
    },
    server: {
        watch: {
            ignored: ['**/.env/**'],
        },
    },
    resolve: {
        alias: {
            "@": "/Users/anujkumar/Downloads/crater/resources",
            "vue-i18n": "vue-i18n/dist/vue-i18n.cjs.js"
        }
    }
}).withPlugins(
    vue
)
