/**
 * Fonvo i18n — lightweight client-side internationalization
 * - Detects browser language on first visit
 * - Persists choice in localStorage
 * - Loads JSON locale files from /locales/
 * - Translates elements with data-i18n attributes
 * - Provides a language picker dropdown
 */

const I18N_KEY = 'fonvo_lang';
const FALLBACK = 'en';

const SUPPORTED_LANGUAGES = {
  en: 'English',
  ar: 'العربية',
  bg: 'Български',
  cs: 'Čeština',
  da: 'Dansk',
  de: 'Deutsch',
  el: 'Ελληνικά',
  es: 'Español',
  fi: 'Suomi',
  fr: 'Français',
  he: 'עברית',
  hi: 'हिन्दी',
  hr: 'Hrvatski',
  hu: 'Magyar',
  id: 'Bahasa Indonesia',
  it: 'Italiano',
  ja: '日本語',
  ko: '한국어',
  ms: 'Bahasa Melayu',
  nl: 'Nederlands',
  no: 'Norsk',
  pl: 'Polski',
  'pt-BR': 'Português (BR)',
  ro: 'Română',
  ru: 'Русский',
  sk: 'Slovenčina',
  sv: 'Svenska',
  th: 'ไทย',
  tr: 'Türkçe',
  uk: 'Українська',
  vi: 'Tiếng Việt',
  'zh-Hans': '简体中文'
};

let currentLocale = FALLBACK;
let translations = {};
let fallbackTranslations = {};

/** Detect best language from browser settings */
function detectLanguage() {
  const saved = localStorage.getItem(I18N_KEY);
  if (saved && SUPPORTED_LANGUAGES[saved]) return saved;

  const browserLangs = navigator.languages || [navigator.language];
  for (const lang of browserLangs) {
    // Exact match first
    if (SUPPORTED_LANGUAGES[lang]) return lang;
    // Try base language (e.g. "pt-BR" -> "pt" won't match, but "de-AT" -> "de" will)
    const base = lang.split('-')[0];
    if (SUPPORTED_LANGUAGES[base]) return base;
    // Special: "pt" -> "pt-BR", "zh" -> "zh-Hans"
    if (base === 'pt') return 'pt-BR';
    if (base === 'zh') return 'zh-Hans';
  }
  return FALLBACK;
}

/** Load a locale JSON file */
async function loadLocale(lang) {
  try {
    const resp = await fetch(`locales/${lang}.json`);
    if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
    return await resp.json();
  } catch {
    console.warn(`[i18n] Failed to load locale: ${lang}`);
    return null;
  }
}

/** Apply translations to all data-i18n elements */
function applyTranslations() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    const text = translations[key] || fallbackTranslations[key];
    if (text) {
      // Use innerHTML to support HTML entities and inline tags
      el.innerHTML = text;
    }
  });

  // Update HTML lang attribute
  document.documentElement.lang = currentLocale;

  // Update dir attribute for RTL languages
  const rtl = ['ar', 'he'];
  document.documentElement.dir = rtl.includes(currentLocale) ? 'rtl' : 'ltr';

  // Update language picker display
  const pickerLabel = document.getElementById('langPickerLabel');
  if (pickerLabel) {
    pickerLabel.textContent = SUPPORTED_LANGUAGES[currentLocale] || currentLocale;
  }

  // Mark active language in dropdown
  document.querySelectorAll('.lang-option').forEach(opt => {
    opt.classList.toggle('active', opt.dataset.lang === currentLocale);
  });
}

/** Switch to a different language */
async function setLanguage(lang) {
  if (!SUPPORTED_LANGUAGES[lang]) lang = FALLBACK;
  currentLocale = lang;
  localStorage.setItem(I18N_KEY, lang);

  if (lang === FALLBACK) {
    translations = fallbackTranslations;
  } else {
    const loaded = await loadLocale(lang);
    translations = loaded || fallbackTranslations;
  }
  applyTranslations();
}

/** Build and inject the language picker into the nav */
function buildLanguagePicker() {
  const picker = document.getElementById('langPicker');
  if (!picker) return;

  const label = document.createElement('span');
  label.id = 'langPickerLabel';
  label.className = 'lang-picker-label';
  label.textContent = SUPPORTED_LANGUAGES[currentLocale];

  const globe = document.createElement('span');
  globe.className = 'lang-picker-icon';
  globe.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>';

  const toggle = document.createElement('button');
  toggle.className = 'lang-picker-toggle';
  toggle.setAttribute('aria-label', 'Select language');
  toggle.appendChild(globe);
  toggle.appendChild(label);

  const dropdown = document.createElement('div');
  dropdown.className = 'lang-dropdown';
  dropdown.style.display = 'none';

  for (const [code, name] of Object.entries(SUPPORTED_LANGUAGES)) {
    const opt = document.createElement('button');
    opt.className = 'lang-option';
    opt.dataset.lang = code;
    opt.textContent = name;
    if (code === currentLocale) opt.classList.add('active');
    opt.addEventListener('click', () => {
      setLanguage(code);
      dropdown.style.display = 'none';
    });
    dropdown.appendChild(opt);
  }

  toggle.addEventListener('click', (e) => {
    e.stopPropagation();
    const isOpen = dropdown.style.display !== 'none';
    dropdown.style.display = isOpen ? 'none' : 'flex';
  });

  document.addEventListener('click', () => {
    dropdown.style.display = 'none';
  });

  picker.appendChild(toggle);
  picker.appendChild(dropdown);
}

/** Initialize i18n on page load */
async function initI18n() {
  // Always load English as fallback
  fallbackTranslations = await loadLocale(FALLBACK) || {};

  // Detect and load target language
  const detected = detectLanguage();
  currentLocale = detected;

  if (detected !== FALLBACK) {
    const loaded = await loadLocale(detected);
    translations = loaded || fallbackTranslations;
  } else {
    translations = fallbackTranslations;
  }

  applyTranslations();
  buildLanguagePicker();
}

// Auto-init when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initI18n);
} else {
  initI18n();
}
