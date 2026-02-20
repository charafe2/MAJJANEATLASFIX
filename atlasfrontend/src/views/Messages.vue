<template>
  <div class="messages-page">

    <!-- ── Page Header ──────────────────────────────────────────────────── -->
    <div class="page-header">
      <div class="header-inner">
        <button class="btn-back" @click="$router.back()">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.67">
            <path d="M19 12H5M5 12l7-7M5 12l7 7" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Retour
        </button>
        <h1 class="page-title">Messages</h1>
      </div>
    </div>

    <!-- ── Main layout ──────────────────────────────────────────────────── -->
    <div class="messages-layout">

      <!-- ── Left: Conversation list ──────────────────────────────────── -->
      <div class="conversations-panel">

        <!-- Search -->
        <div class="search-bar">
          <div class="search-wrap">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher..."
              class="search-input"
            />
            <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.67">
              <circle cx="11" cy="11" r="8"/>
              <path d="M21 21l-4.35-4.35" stroke-linecap="round"/>
            </svg>
          </div>
        </div>

        <!-- Conversations -->
        <div class="conv-list">
          <div v-if="loadingConv" class="conv-spinner">
            <div class="spinner"></div>
          </div>

          <div
            v-for="conv in filteredConversations"
            :key="conv.id"
            class="conv-item"
            :class="{ 'conv-item--active': selectedId === conv.id }"
            @click="selectConversation(conv.id)"
          >
            <!-- Avatar -->
            <div class="conv-avatar-wrap">
              <div class="conv-avatar" :style="{ background: avatarColor(conv.other_name) }">
                <img
                  v-if="conv.other_avatar"
                  :src="conv.other_avatar"
                  :alt="conv.other_name"
                  class="conv-avatar-img"
                />
                <span v-else>{{ initials(conv.other_name) }}</span>
              </div>
              <span class="conv-online-dot"></span>
              <span v-if="conv.unread_count > 0" class="conv-unread-badge">
                {{ conv.unread_count > 9 ? '9+' : conv.unread_count }}
              </span>
            </div>

            <!-- Info -->
            <div class="conv-info">
              <div class="conv-info-row">
                <span class="conv-name">{{ conv.other_name }}</span>
                <span class="conv-time">{{ formatConvTime(conv.last_message_at) }}</span>
              </div>
              <span
                class="conv-preview"
                :class="{ 'conv-preview--unread': conv.unread_count > 0 }"
              >
                {{ conv.last_message || 'Démarrer une conversation…' }}
              </span>
            </div>
          </div>

          <div v-if="!loadingConv && filteredConversations.length === 0" class="conv-empty">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#D1D5DB" stroke-width="1.5">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
            </svg>
            <p>Aucune conversation</p>
          </div>
        </div>
      </div>

      <!-- ── Right: Chat panel ─────────────────────────────────────────── -->
      <div class="chat-panel" v-if="activeConv">

        <!-- Chat header -->
        <div class="chat-header">
          <div class="chat-header-left">
            <div class="chat-avatar-wrap">
              <div class="chat-avatar" :style="{ background: avatarColor(activeConv.other_name) }">
                <img
                  v-if="activeConv.other_avatar"
                  :src="activeConv.other_avatar"
                  :alt="activeConv.other_name"
                  class="chat-avatar-img"
                />
                <span v-else>{{ initials(activeConv.other_name) }}</span>
              </div>
              <span class="chat-online-dot"></span>
            </div>
            <div class="chat-contact-info">
              <span class="chat-contact-name">{{ activeConv.other_name }}</span>
              <span class="chat-contact-role">{{ activeConv.other_role }}</span>
            </div>
          </div>

          <div class="chat-header-actions">
            <button class="chat-action-btn" title="Appel vocal">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#62748E" stroke-width="1.67">
                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.62 3.38 2 2 0 0 1 3.6 1h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.5a16 16 0 0 0 6 6l.96-.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
              </svg>
            </button>
            <button class="chat-action-btn" title="Appel vidéo">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#62748E" stroke-width="1.67">
                <polygon points="23 7 16 12 23 17 23 7"/>
                <rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>
              </svg>
            </button>
            <button class="chat-action-btn chat-action-btn--danger" title="Signaler">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="1.67">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="12"/>
                <circle cx="12" cy="16" r="0.5" fill="#EF4444"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Messages area -->
        <div class="messages-area" ref="messagesAreaRef">
          <div v-if="loadingMsgs" class="messages-spinner">
            <div class="spinner"></div>
          </div>

          <div v-else class="messages-list">
            <div
              v-for="msg in messages"
              :key="msg.id"
              class="msg-row"
              :class="msg.sender_id === currentUserId ? 'msg-row--mine' : 'msg-row--theirs'"
            >
              <div
                class="msg-bubble"
                :class="msg.sender_id === currentUserId ? 'msg-bubble--mine' : 'msg-bubble--theirs'"
              >
                <p class="msg-content">{{ msg.content }}</p>
                <span class="msg-time">{{ formatMsgTime(msg.created_at) }}</span>
              </div>
            </div>

            <div v-if="messages.length === 0" class="no-messages">
              <p>Commencez la conversation en envoyant un message.</p>
            </div>
          </div>
        </div>

        <!-- Input area -->
        <div class="chat-input-area">
          <div class="chat-input-inner">
            <button class="input-icon-btn" title="Pièce jointe">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#62748E" stroke-width="1.67">
                <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
            <button class="input-icon-btn" title="Image">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#62748E" stroke-width="1.67">
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                <circle cx="8.5" cy="8.5" r="1.5"/>
                <polyline points="21 15 16 10 5 21"/>
              </svg>
            </button>
            <input
              v-model="newMessage"
              type="text"
              placeholder="Écrivez votre message..."
              class="message-input"
              @keydown.enter.prevent="sendMessage"
            />
            <button
              class="send-btn"
              :class="{ 'send-btn--active': newMessage.trim() }"
              :disabled="!newMessage.trim() || sending"
              @click="sendMessage"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="1.67">
                <line x1="22" y1="2" x2="11" y2="13"/>
                <polygon points="22 2 15 22 11 13 2 9 22 2"/>
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- ── Empty state ───────────────────────────────────────────────── -->
      <div class="chat-empty" v-else>
        <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="#D1D5DB" stroke-width="1.5">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
        </svg>
        <p>Sélectionnez une conversation pour commencer</p>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  getConversations,
  getConversation,
  getMessages,
  sendMessageApi,
  markAsRead,
} from '../api/messages'

const router = useRouter()
const route  = useRoute()

// ── State ──────────────────────────────────────────────────────────────────
const conversations = ref([])
const loadingConv   = ref(false)
const searchQuery   = ref('')

const selectedId    = ref(null)
const activeConv    = ref(null)
const messages      = ref([])
const loadingMsgs   = ref(false)

const newMessage    = ref('')
const sending       = ref(false)

const messagesAreaRef = ref(null)

// ── Current user id ────────────────────────────────────────────────────────
const currentUserId = computed(() => {
  try {
    return JSON.parse(localStorage.getItem('user'))?.id ?? null
  } catch {
    return null
  }
})

// ── Filtered list ──────────────────────────────────────────────────────────
const filteredConversations = computed(() => {
  if (!searchQuery.value.trim()) return conversations.value
  const q = searchQuery.value.toLowerCase()
  return conversations.value.filter(c =>
    c.other_name.toLowerCase().includes(q) ||
    (c.last_message || '').toLowerCase().includes(q)
  )
})

// ── Load conversations ─────────────────────────────────────────────────────
async function loadConversations(silent = false) {
  if (!silent) loadingConv.value = true
  try {
    const { data } = await getConversations()
    conversations.value = data.data ?? []
  } catch {
    if (!silent) conversations.value = []
  } finally {
    loadingConv.value = false
  }
}

// ── Select a conversation ──────────────────────────────────────────────────
async function selectConversation(id) {
  if (selectedId.value === id) return
  selectedId.value = id
  messages.value   = []
  activeConv.value = null

  // Update URL without triggering nav guard
  router.replace(`/messages/${id}`)

  // Fetch header info
  try {
    const { data } = await getConversation(id)
    activeConv.value = data.data
  } catch {
    // Fall back to conversation list data
    const found = conversations.value.find(c => c.id === id)
    if (found) {
      activeConv.value = {
        id:           found.id,
        other_name:   found.other_name,
        other_avatar: found.other_avatar,
        other_role:   found.other_role,
        status:       found.status,
      }
    }
  }

  // Load messages
  await loadMessages(id)
}

async function loadMessages(id, silent = false) {
  if (!id) return
  if (!silent) loadingMsgs.value = true
  try {
    const { data } = await getMessages(id)
    messages.value = data.data ?? []
    await markAsRead(id)
    // Clear local unread badge
    const conv = conversations.value.find(c => c.id === id)
    if (conv) conv.unread_count = 0
    scrollToBottom()
  } catch {
    if (!silent) messages.value = []
  } finally {
    loadingMsgs.value = false
  }
}

// ── Send message ──────────────────────────────────────────────────────────
async function sendMessage() {
  const content = newMessage.value.trim()
  if (!content || !selectedId.value || sending.value) return

  sending.value = true

  // Optimistic insert
  const tempId = `tmp-${Date.now()}`
  messages.value.push({
    id:              tempId,
    conversation_id: selectedId.value,
    sender_id:       currentUserId.value,
    content,
    message_type:    'text',
    is_read:         false,
    created_at:      new Date().toISOString(),
  })
  newMessage.value = ''
  scrollToBottom()

  try {
    const { data } = await sendMessageApi(selectedId.value, content)
    // Replace temp message with the real one
    const idx = messages.value.findIndex(m => m.id === tempId)
    if (idx !== -1) messages.value.splice(idx, 1, data.data)

    // Update conversation last message preview
    const conv = conversations.value.find(c => c.id === selectedId.value)
    if (conv) {
      conv.last_message    = content
      conv.last_message_at = new Date().toISOString()
    }
  } catch {
    // Remove the optimistic message on failure and restore input
    messages.value   = messages.value.filter(m => m.id !== tempId)
    newMessage.value = content
  } finally {
    sending.value = false
  }
}

// ── Polling ────────────────────────────────────────────────────────────────
let msgTimer  = null
let convTimer = null

async function pollMessages() {
  if (!selectedId.value) return
  try {
    const { data } = await getMessages(selectedId.value)
    const fresh = data.data ?? []
    if (fresh.length !== messages.value.length) {
      messages.value = fresh
      await markAsRead(selectedId.value)
      const conv = conversations.value.find(c => c.id === selectedId.value)
      if (conv) conv.unread_count = 0
      scrollToBottom()
    }
  } catch { /* ignore */ }
}

// ── Scroll helpers ─────────────────────────────────────────────────────────
async function scrollToBottom() {
  await nextTick()
  if (messagesAreaRef.value) {
    messagesAreaRef.value.scrollTop = messagesAreaRef.value.scrollHeight
  }
}

// ── Formatters ─────────────────────────────────────────────────────────────
function formatConvTime(iso) {
  if (!iso) return ''
  const d    = new Date(iso)
  const now  = new Date()
  const diff = Math.floor((now - d) / 86400000)
  if (diff === 0) return d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  if (diff === 1) return 'Hier'
  if (diff < 7)   return d.toLocaleDateString('fr-FR', { weekday: 'short' })
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}

function formatMsgTime(iso) {
  if (!iso) return ''
  return new Date(iso).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

function initials(name) {
  if (!name) return '?'
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)
}

const COLORS = ['#FC5A15', '#3B82F6', '#8B5CF6', '#10B981', '#F59E0B', '#EF4444', '#06B6D4', '#84CC16']
function avatarColor(name) {
  if (!name) return COLORS[0]
  let h = 0
  for (const c of name) h = (h * 31 + c.charCodeAt(0)) % COLORS.length
  return COLORS[h]
}

// ── Lifecycle ──────────────────────────────────────────────────────────────
onMounted(async () => {
  await loadConversations()

  // Open conversation from route param
  const routeId = route.params.id ? Number(route.params.id) : null
  if (routeId) {
    await selectConversation(routeId)
  }

  // Polling
  msgTimer  = setInterval(pollMessages, 4000)
  convTimer = setInterval(() => loadConversations(true), 12000)
})

onUnmounted(() => {
  clearInterval(msgTimer)
  clearInterval(convTimer)
})

// React to route param changes (e.g., navigate between conversations)
watch(() => route.params.id, async (newId) => {
  if (newId && Number(newId) !== selectedId.value) {
    await selectConversation(Number(newId))
  }
})
</script>

<style scoped>
/* ── Base ─────────────────────────────────────────────────────────────────── */
.messages-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #FFF7ED 0%, #FFFFFF 100%);
  font-family: 'Inter', sans-serif;
  display: flex;
  flex-direction: column;
}

/* ── Page header ──────────────────────────────────────────────────────────── */
.page-header {
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
}
.header-inner {
  max-width: 1440px;
  margin: 0 auto;
  padding: 0 192px;
  display: flex;
  flex-direction: column;
  gap: 0;
  min-height: 125px;
  justify-content: center;
}
.btn-back {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: none;
  color: #62748E;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  letter-spacing: -0.3125px;
  cursor: pointer;
  padding: 0;
  margin-bottom: 16px;
  width: fit-content;
}
.btn-back:hover { color: #314158; }
.page-title {
  font-size: 30px;
  font-weight: 400;
  color: #314158;
  letter-spacing: 0.395508px;
  margin: 0;
  line-height: 36px;
}

/* ── Layout ───────────────────────────────────────────────────────────────── */
.messages-layout {
  flex: 1;
  display: flex;
  max-width: 1440px;
  width: 100%;
  margin: 24px auto;
  padding: 0 192px;
  gap: 24px;
  box-sizing: border-box;
  min-height: 0;
  height: calc(100vh - 200px);
}

/* ── Conversations panel ──────────────────────────────────────────────────── */
.conversations-panel {
  width: 360px;
  flex-shrink: 0;
  background: #F9FAFB;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid #E5E7EB;
}

/* Search */
.search-bar {
  background: #fff;
  border-bottom: 1px solid #E5E7EB;
  padding: 16px;
}
.search-wrap {
  position: relative;
  display: flex;
  align-items: center;
}
.search-input {
  width: 100%;
  padding: 10px 40px 10px 16px;
  background: #F9FAFB;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  color: #314158;
  outline: none;
  box-sizing: border-box;
}
.search-input::placeholder { color: rgba(10, 10, 10, 0.5); }
.search-icon {
  position: absolute;
  right: 12px;
  color: #62748E;
  pointer-events: none;
}

/* Conversation list */
.conv-list {
  flex: 1;
  overflow-y: auto;
}
.conv-spinner {
  display: flex;
  justify-content: center;
  padding: 32px;
}
.conv-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 16px 16px 24px;
  cursor: pointer;
  background: transparent;
  border-bottom: 1px solid #F3F4F6;
  transition: background 0.15s;
}
.conv-item:hover { background: #F3F4F6; }
.conv-item--active {
  background: #fff;
  box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.1), 0px 1px 2px -1px rgba(0, 0, 0, 0.1);
}

/* Avatar */
.conv-avatar-wrap {
  position: relative;
  flex-shrink: 0;
}
.conv-avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 16px;
  font-weight: 500;
  overflow: hidden;
}
.conv-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.conv-online-dot {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 16px;
  height: 16px;
  background: #00C950;
  border: 2px solid #fff;
  border-radius: 50%;
}
.conv-unread-badge {
  position: absolute;
  top: -4px;
  right: -4px;
  min-width: 20px;
  height: 20px;
  background: #FC5A15;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #fff;
  padding: 0 4px;
  box-sizing: border-box;
}

/* Info */
.conv-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.conv-info-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}
.conv-name {
  font-size: 16px;
  color: #314158;
  letter-spacing: -0.3125px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.conv-time {
  font-size: 12px;
  color: #62748E;
  white-space: nowrap;
  flex-shrink: 0;
}
.conv-preview {
  font-size: 14px;
  color: #62748E;
  letter-spacing: -0.150391px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.conv-preview--unread {
  color: #314158;
  font-weight: 500;
}

.conv-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 48px 24px;
  color: #9CA3AF;
  font-size: 14px;
  text-align: center;
}

/* ── Chat panel ───────────────────────────────────────────────────────────── */
.chat-panel {
  flex: 1;
  min-width: 0;
  background: #fff;
  border: 1px solid #E5E7EB;
  box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.1), 0px 1px 2px -1px rgba(0, 0, 0, 0.1);
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* Chat header */
.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  height: 81px;
  border-bottom: 1px solid #E5E7EB;
  flex-shrink: 0;
}
.chat-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}
.chat-avatar-wrap {
  position: relative;
}
.chat-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 15px;
  font-weight: 500;
  overflow: hidden;
}
.chat-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.chat-online-dot {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 14px;
  height: 14px;
  background: #00C950;
  border: 2px solid #fff;
  border-radius: 50%;
}
.chat-contact-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.chat-contact-name {
  font-size: 16px;
  color: #314158;
  letter-spacing: -0.3125px;
}
.chat-contact-role {
  font-size: 14px;
  color: #62748E;
  letter-spacing: -0.150391px;
}

/* Header action buttons */
.chat-header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.chat-action-btn {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: background 0.15s;
}
.chat-action-btn:hover { background: #F3F4F6; }
.chat-action-btn--danger:hover { background: #FEF2F2; }

/* Messages area */
.messages-area {
  flex: 1;
  background: #F9FAFB;
  overflow-y: auto;
  padding: 16px;
  min-height: 0;
}
.messages-spinner {
  display: flex;
  justify-content: center;
  padding: 32px;
}
.messages-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.no-messages {
  text-align: center;
  color: #9CA3AF;
  font-size: 14px;
  padding: 40px 0;
}

/* Message rows */
.msg-row {
  display: flex;
}
.msg-row--mine   { justify-content: flex-end; }
.msg-row--theirs { justify-content: flex-start; }

/* Bubbles */
.msg-bubble {
  max-width: 60%;
  padding: 10px 16px 4px;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.msg-bubble--mine {
  background: #FC5A15;
  border-bottom-right-radius: 4px;
}
.msg-bubble--theirs {
  background: #fff;
  border: 1px solid #E5E7EB;
  border-bottom-left-radius: 4px;
}
.msg-content {
  font-size: 14px;
  line-height: 23px;
  letter-spacing: -0.150391px;
  margin: 0;
  word-break: break-word;
}
.msg-bubble--mine   .msg-content { color: #fff; }
.msg-bubble--theirs .msg-content { color: #314158; }
.msg-time {
  font-size: 12px;
  line-height: 16px;
  align-self: flex-end;
}
.msg-bubble--mine   .msg-time { color: #FFEDD4; }
.msg-bubble--theirs .msg-time { color: #62748E; }

/* Input area */
.chat-input-area {
  background: #fff;
  border-top: 1px solid #E5E7EB;
  padding: 17px 16px;
  flex-shrink: 0;
}
.chat-input-inner {
  display: flex;
  align-items: center;
  gap: 0;
}
.input-icon-btn {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  flex-shrink: 0;
  transition: background 0.15s;
}
.input-icon-btn:hover { background: #F3F4F6; }
.message-input {
  flex: 1;
  height: 44px;
  padding: 10px 16px;
  background: #F9FAFB;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-family: 'Inter', sans-serif;
  color: #314158;
  outline: none;
  margin: 0 12px;
}
.message-input::placeholder { color: rgba(10, 10, 10, 0.5); }
.send-btn {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #D1D5DB;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  flex-shrink: 0;
  transition: background 0.15s;
}
.send-btn--active,
.send-btn:not(:disabled):hover {
  background: #FC5A15;
}
.send-btn:disabled { cursor: not-allowed; }

/* ── Empty chat state ─────────────────────────────────────────────────────── */
.chat-empty {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  color: #9CA3AF;
  font-size: 16px;
  background: #fff;
  border: 1px solid #E5E7EB;
  border-radius: 14px;
}

/* ── Spinner ──────────────────────────────────────────────────────────────── */
.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #E8ECF0;
  border-top-color: #FC5A15;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ── Responsive ───────────────────────────────────────────────────────────── */
@media (max-width: 1200px) {
  .header-inner       { padding: 0 48px; }
  .messages-layout    { padding: 0 48px; }
}
@media (max-width: 960px) {
  .header-inner       { padding: 0 24px; }
  .messages-layout    { padding: 0 24px; gap: 16px; }
  .conversations-panel { width: 280px; }
}
@media (max-width: 700px) {
  .header-inner       { padding: 0 16px; }
  .messages-layout    {
    padding: 16px;
    flex-direction: column;
    height: auto;
  }
  .conversations-panel { width: 100%; max-height: 280px; }
  .chat-panel         { min-height: 400px; }
}
</style>
