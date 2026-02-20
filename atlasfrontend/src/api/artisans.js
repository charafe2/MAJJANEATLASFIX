import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
})

/**
 * Fetch all active service categories (public – no auth required).
 */
export const getPublicCategories = () =>
  api.get('/public/categories')

/**
 * Fetch artisans for a given category (public – no auth required).
 *
 * @param {Object} params  – { category_id, search, page, per_page }
 */
export const getPublicArtisans = (params = {}) =>
  api.get('/public/artisans', { params })
