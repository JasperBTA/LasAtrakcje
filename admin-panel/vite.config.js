import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // This enables access from local network (0.0.0.0)
    proxy: {
      '/api': {
        target: 'https://localhost:8080',
        secure: false,
        changeOrigin: true
      }
    }
  }
})
