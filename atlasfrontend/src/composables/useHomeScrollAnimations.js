import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger)

// Shorthand: animate element(s) from hidden → visible when they enter the viewport
function reveal(targets, vars, triggerEl) {
  if (!document.querySelector(targets)) return
  gsap.from(targets, {
    scrollTrigger: {
      trigger: triggerEl || targets,
      start: 'top 85%',
      toggleActions: 'play none none none'
    },
    opacity: 0,
    y: 40,
    duration: 0.8,
    ease: 'power2.out',
    ...vars
  })
}

export function useHomeScrollAnimations() {
  function init() {
    // ── Hero (already in viewport → no ScrollTrigger, plain entrance) ──────
    const heroTL = gsap.timeline({ defaults: { ease: 'power2.out' } })
    heroTL
      .from('.hs-title',    { opacity: 0, y: 50, duration: 0.9 })
      .from('.hs-subtitle', { opacity: 0, y: 35, duration: 0.8 }, '-=0.5')
      .from('.hs-search',   { opacity: 0, y: 30, duration: 0.8 }, '-=0.5')
      .from('.hs-badge',    { opacity: 0, y: 20, duration: 0.6, stagger: 0.15 }, '-=0.4')

    // ── Published / Post a need ──────────────────────────────────────────────
    reveal('.pn-title-block', { x: -50, y: 0 }, '.pn-section')
    reveal('.pn-step', { y: 30, stagger: 0.15, duration: 0.7 }, '.pn-steps')

    // ── Services ─────────────────────────────────────────────────────────────
    reveal('.services-section .section-title',    { y: 35, duration: 0.8 }, '.services-section')
    reveal('.services-section .section-subtitle', { y: 25, duration: 0.7, delay: 0.1 }, '.services-section')
    reveal('.service-card', { y: 50, stagger: 0.1, duration: 0.65 }, '.carousel-wrapper')

    // ── About ─────────────────────────────────────────────────────────────────
    reveal('.ab-image-wrap', { x: -60, y: 0, duration: 1 },   '.ab-section')
    reveal('.ab-content',    { x:  60, y: 0, duration: 1, delay: 0.15 }, '.ab-section')
    reveal('.ab-feature',    { y: 30, stagger: 0.14, duration: 0.65 }, '.ab-features')

    // ── How it works ──────────────────────────────────────────────────────────
    reveal('.hiw-title', { y: 35, duration: 0.8 }, '.hiw-section')
    reveal('.hiw-step',  { y: 40, stagger: 0.15, duration: 0.7 }, '.hiw-steps')

    // ── Testimonials ──────────────────────────────────────────────────────────
    reveal('.tm-title', { y: 35, duration: 0.8 }, '.tm-section')
    reveal('.tm-card',  { y: 30, stagger: 0.12, duration: 0.65 }, '.tm-track')

    // ── Top Artisans ──────────────────────────────────────────────────────────
    reveal('.ta-title',    { y: 35, duration: 0.8 }, '.ta-section')
    reveal('.ta-subtitle', { y: 25, duration: 0.7, delay: 0.1 }, '.ta-section')
    reveal('.ta-card',     { y: 40, stagger: 0.12, duration: 0.65 }, '.ta-track')

    // ── App Download ──────────────────────────────────────────────────────────
    reveal('.ad-phone-wrap', { x: -60, y: 0, duration: 1 }, '.ad-section')
    reveal('.ad-content',    { x:  60, y: 0, duration: 1, delay: 0.15 }, '.ad-section')
    reveal('.ad-title',      { y: 30, duration: 0.8 }, '.ad-section')
  }

  function cleanup() {
    ScrollTrigger.getAll().forEach(t => t.kill())
    gsap.killTweensOf([
      '.hs-title', '.hs-subtitle', '.hs-search', '.hs-badge',
      '.pn-title-block', '.pn-step',
      '.section-title', '.section-subtitle', '.service-card',
      '.ab-image-wrap', '.ab-content', '.ab-feature',
      '.hiw-title', '.hiw-step',
      '.tm-title', '.tm-card',
      '.ta-title', '.ta-subtitle', '.ta-card',
      '.ad-phone-wrap', '.ad-content', '.ad-title'
    ])
  }

  return { init, cleanup }
}
