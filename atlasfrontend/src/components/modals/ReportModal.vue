<template>
  <transition name="modal-fade">
    <div v-if="show" class="rm-overlay" @click.self="handleClose">
      <div class="rm-card">

        <!-- Header -->
        <div class="rm-header">
          <div class="rm-header-left">
            <div class="rm-icon-wrap">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                <line x1="12" y1="9" x2="12" y2="13" /><line x1="12" y1="17" x2="12.01" y2="17" />
              </svg>
            </div>
            <span class="rm-title">Signaler un problème</span>
          </div>
          <button class="rm-close" @click="handleClose">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <!-- Body -->
        <div class="rm-body">

          <!-- Message -->
          <div class="rm-field">
            <label class="rm-label">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FC5A15" stroke-width="2">
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
              </svg>
              Message
            </label>
            <textarea
              v-model="message"
              class="rm-textarea"
              rows="4"
              placeholder="Décrivez le problème rencontré…"
            ></textarea>
          </div>

          <!-- Photos -->
          <div class="rm-field">
            <label class="rm-label">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#FC5A15" stroke-width="2">
                <rect x="3" y="3" width="18" height="18" rx="2" />
                <circle cx="8.5" cy="8.5" r="1.5" />
                <polyline points="21 15 16 10 5 21" />
              </svg>
              Photos de vos problème *
            </label>

            <div
              class="rm-dropzone"
              :class="{ 'rm-dropzone--over': dragOver }"
              @dragover.prevent="dragOver = true"
              @dragleave.prevent="dragOver = false"
              @drop.prevent="onDrop"
              @click="$refs.fileInput.click()"
            >
              <input
                ref="fileInput"
                type="file"
                accept="image/jpg,image/jpeg,image/png,image/webp"
                multiple
                class="rm-file-hidden"
                @change="onFileChange"
              />

              <template v-if="previews.length === 0">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#9CA3AF" stroke-width="1.5">
                  <polyline points="16 16 12 12 8 16" /><line x1="12" y1="12" x2="12" y2="21" />
                  <path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3" />
                </svg>
                <p class="rm-dropzone-hint">Cliquez pour télécharger ou glissez vos images</p>
                <p class="rm-dropzone-sub">PNG, JPG jusqu'à 10MB (minimum 3 photos)</p>
              </template>

              <div v-else class="rm-previews">
                <div v-for="(src, i) in previews" :key="i" class="rm-preview-item">
                  <img :src="src" alt="preview" />
                  <button class="rm-preview-remove" @click.stop="removePhoto(i)">×</button>
                </div>
                <div class="rm-preview-add" @click.stop="$refs.fileInput.click()">+</div>
              </div>
            </div>
          </div>

          <!-- Error -->
          <p v-if="error" class="rm-error">{{ error }}</p>

          <!-- Submit -->
          <button
            class="rm-submit-btn"
            :disabled="submitting"
            @click="submit"
          >
            {{ submitting ? 'Envoi en cours…' : 'Envoyer' }}
          </button>

        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  show:             { type: Boolean, default: false },
  serviceRequestId: { type: [Number, String], required: true },
})

const emit = defineEmits(['close', 'success'])

const message    = ref('')
const photos     = ref([])   // File objects
const previews   = ref([])   // Data-URL strings
const dragOver   = ref(false)
const submitting = ref(false)
const error      = ref('')

// Reset when modal opens
watch(() => props.show, (val) => {
  if (val) {
    message.value  = ''
    photos.value   = []
    previews.value = []
    error.value    = ''
  }
})

function handleClose() {
  if (submitting.value) return
  emit('close')
}

function addFiles(files) {
  for (const file of files) {
    if (!file.type.startsWith('image/')) continue
    photos.value.push(file)
    const reader = new FileReader()
    reader.onload = e => previews.value.push(e.target.result)
    reader.readAsDataURL(file)
  }
}

function onFileChange(e) {
  addFiles(e.target.files)
  e.target.value = ''
}

function onDrop(e) {
  dragOver.value = false
  addFiles(e.dataTransfer.files)
}

function removePhoto(index) {
  photos.value.splice(index, 1)
  previews.value.splice(index, 1)
}

async function submit() {
  error.value = ''
  if (!message.value.trim()) {
    error.value = 'Veuillez décrire le problème.'
    return
  }
  if (photos.value.length < 3) {
    error.value = 'Veuillez ajouter au minimum 3 photos.'
    return
  }

  submitting.value = true
  try {
    const form = new FormData()
    form.append('message', message.value.trim())
    photos.value.forEach(f => form.append('photos[]', f))

    const token = localStorage.getItem('token')
    const res = await fetch(`/api/client/service-requests/${props.serviceRequestId}/report`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, Accept: 'application/json' },
      body: form,
    })
    const body = await res.json()
    if (!res.ok) throw new Error(body.error || body.message || 'Erreur')
    emit('success', body)
  } catch (e) {
    error.value = e.message || 'Impossible d\'envoyer le signalement.'
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.rm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 24px;
  backdrop-filter: blur(3px);
}

.rm-card {
  background: #fff;
  border-radius: 18px;
  width: 100%;
  max-width: 440px;
  box-shadow: 0 24px 64px rgba(0,0,0,0.18);
  overflow: hidden;
}

.rm-header {
  background: linear-gradient(135deg, #FC5A15, #e04e0e);
  padding: 18px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.rm-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.rm-icon-wrap {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.rm-title {
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 700;
  color: #fff;
}

.rm-close {
  background: rgba(255,255,255,0.15);
  border: none;
  border-radius: 8px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  cursor: pointer;
  transition: background 0.15s;
}
.rm-close:hover { background: rgba(255,255,255,0.28); }

.rm-body {
  padding: 22px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.rm-field { display: flex; flex-direction: column; gap: 6px; }

.rm-label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #374151;
}

.rm-textarea {
  width: 100%;
  box-sizing: border-box;
  border: 1.5px solid #E5E7EB;
  border-radius: 10px;
  padding: 10px 14px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  color: #1E293B;
  resize: vertical;
  outline: none;
  background: #FAFAFA;
  transition: border-color 0.15s;
}
.rm-textarea:focus { border-color: #FC5A15; background: #fff; }

.rm-dropzone {
  border: 2px dashed #D1D5DB;
  border-radius: 12px;
  padding: 20px;
  text-align: center;
  cursor: pointer;
  background: #F9FAFB;
  transition: border-color 0.15s, background 0.15s;
  min-height: 110px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
}
.rm-dropzone:hover,
.rm-dropzone--over { border-color: #FC5A15; background: #FFF7ED; }

.rm-dropzone-hint {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #374151;
  margin: 0;
}
.rm-dropzone-sub {
  font-family: 'Inter', sans-serif;
  font-size: 12px;
  color: #9CA3AF;
  margin: 0;
}

.rm-previews {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: flex-start;
  width: 100%;
}

.rm-preview-item {
  position: relative;
  width: 72px;
  height: 72px;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}
.rm-preview-item img { width: 100%; height: 100%; object-fit: cover; }

.rm-preview-remove {
  position: absolute;
  top: 2px;
  right: 2px;
  width: 18px;
  height: 18px;
  background: rgba(0,0,0,0.6);
  color: #fff;
  border: none;
  border-radius: 50%;
  font-size: 12px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.rm-preview-add {
  width: 72px;
  height: 72px;
  border: 2px dashed #D1D5DB;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #9CA3AF;
  cursor: pointer;
  flex-shrink: 0;
  transition: border-color 0.15s, color 0.15s;
}
.rm-preview-add:hover { border-color: #FC5A15; color: #FC5A15; }

.rm-error {
  font-family: 'Inter', sans-serif;
  font-size: 13px;
  color: #DC2626;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 0;
}

.rm-file-hidden { display: none; }

.rm-submit-btn {
  width: 100%;
  height: 48px;
  background: #FC5A15;
  color: #fff;
  border: none;
  border-radius: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s, transform 0.1s;
}
.rm-submit-btn:hover:not(:disabled) { background: #e04e0e; }
.rm-submit-btn:active:not(:disabled) { transform: scale(0.98); }
.rm-submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }

/* Transition */
.modal-fade-enter-active,
.modal-fade-leave-active { transition: opacity 0.2s; }
.modal-fade-enter-active .rm-card,
.modal-fade-leave-active .rm-card { transition: transform 0.2s, opacity 0.2s; }
.modal-fade-enter-from,
.modal-fade-leave-to { opacity: 0; }
.modal-fade-enter-from .rm-card,
.modal-fade-leave-to .rm-card { transform: scale(0.95) translateY(8px); opacity: 0; }
</style>
