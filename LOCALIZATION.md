# Localization notes

## The `ripple` animation string

The `ripple` animation type shipped without a localization entry in any of the
55 `Localizable.strings` files, so it rendered as the raw lowercase key `ripple`
in the options menu, next to a properly capitalized None / Bloom / Jitter.

It now has a translation in every language. Each was chosen to match the register
of that file's existing `none` / `bloom` / `jitter` entries — verbal noun,
infinitive, or plain noun — rather than translated in isolation. The sense is an
undulating wave travelling through the letters.

Verified: all 55 files pass `plutil -lint`, the iOS build is clean, and the
Spanish build was checked at runtime in the simulator (shows **Ondular** next to
**Temblar**).

### Confidence

Machine-translated without a native-speaker review. Ordered by how much
verification each one wants before you consider the localization final.

#### Needs a native speaker (5)

Best effort. These use scripts and languages where I would not ship without a check.

| Lang | `ripple` | Note |
|---|---|---|
| `am` | ማዕበል | wave; verify register vs መንቀጥቀጥ |
| `bo` | རླབས | wave; Tibetan needs native check |
| `ha` | Kaɗawa | swaying/fluttering; Hausa needs native check |
| `si` | රැල්ල | wave; Sinhala needs native check |
| `zu` | Amagagasi | waves; Zulu needs native check |

#### Correct sense, confirm register (15)

The meaning is right; a native speaker may prefer a different word form.

| Lang | `ripple` | Note |
|---|---|---|
| `be` | Хваля | wave; verbal-noun alt: Хваляванне |
| `bn` | ঢেউ | wave; verify vs কাঁপুনি register |
| `eu` | Uhindura | undulation; confirm vs Dardara |
| `fil` | Umalon | verb form matching Mamulaklak/Manginig |
| `ga` | Tonnú | undulating; confirm vs Creathadh |
| `gu` | લહેર | wave |
| `kn` | ಅಲೆ | wave |
| `mn` | Долгион | wave |
| `ne` | लहर | wave |
| `pa` | ਲਹਿਰ | wave |
| `sw` | Mawimbi | waves |
| `ta` | அலை | wave |
| `te` | అల | wave |
| `th` | ระลอกคลื่น | ripple |
| `uz` | To'lqin | wave |

#### Confident (34)

| Lang | `ripple` | Note |
|---|---|---|
| `af` | Rimpeling | matches noun style of Bewing |
| `ar` | تموج | undulation, matches اهتزاز |
| `ca` | Ondulació | noun, matches Tremolor |
| `cs` | Vlnění | verbal noun, matches Chvění |
| `da` | Krusning | matches Rystelse |
| `de` | Kräuseln | infinitive, matches Blühen/Zittern |
| `el` | Κυματισμός | undulation, matches Τρόμος |
| `es` | Ondular | infinitive, matches Florecer/Temblar |
| `fa` | موج | wave |
| `fi` | Aaltoilu | undulation, matches Tärinä |
| `fr` | Ondulation | noun, matches Tremblement |
| `fr-CA` | Ondulation | same as fr |
| `he` | אדווה | ripple (on water) |
| `hi` | लहर | wave |
| `hu` | Hullámzás | undulation, matches Remegés |
| `id` | Beriak | to ripple, matches Mekar/Gemetar |
| `it` | Increspatura | ripple, matches Tremolio |
| `ja` | 波紋 | ripple |
| `ko` | 물결 | ripple/wave |
| `ms` | Beriak | to ripple, matches Mekar |
| `nl` | Rimpeling | matches Trilling |
| `pl` | Falowanie | undulation, matches Drżenie |
| `pt` | Ondulação | matches Tremor |
| `pt-BR` | Ondulação | same as pt |
| `ro` | Ondulare | matches Tremur |
| `ru` | Волна | wave; reads naturally in UI |
| `sk` | Vlnenie | matches Chvenie |
| `sv` | Krusning | matches Skaka |
| `tr` | Dalgalanma | undulation, matches Titreme |
| `uk` | Хвиля | wave |
| `ur` | لہر | wave |
| `vi` | Gợn sóng | ripple |
| `zh-Hans` | 波纹 | ripple |
| `zh-Hant` | 波紋 | ripple |

## Removed: the `explode` key

All 55 files carried an `"explode"` entry left over from an animation type that
no longer exists — `TextAnimation` is now `none` / `bloom` / `jitter` / `ripple`.
Removed from every file.

## The Theme/Display and Welcome-screen strings

Closed. 41 keys that were English literals in `OptionsMenuSheet.swift`,
`ContentViewState.swift` (`AppearanceMode.localizedName` /
`TextRotation.localizedName`), and `WelcomeView.swift` are now
`LocalizedStringKey` lookups with entries in all 55 `Localizable.strings` files
(72 keys total per file, all matching `en.lproj`).

This was the mismatch described below in the original "known gap" writeup: a
Spanish user saw "Ondular" and "Temblar" (translated Animation section) directly
above an English "Theme" and "Random Theme (Daily)" (hardcoded Display section).
Verified at runtime in the iOS Simulator with `-AppleLanguages "(es)"` — both the
options sheet (**Tema**, **Tema aleatorio (diario)**, **Apariencia**, **Rotación
del texto**, **Fuente serif**, **Espaciado entre letras**, **Líneas máx.**) and
the welcome screen (**¡Bienvenido a Giant Text!**, bullet points, **Comenzar**
button) now render fully in Spanish.

`BulletPoint` and `FeatureRow` (in `WelcomeView.swift`) now take
`LocalizedStringKey` instead of `String`, and the `#if os(...)` branches that had
duplicated English copy across platforms (e.g. "Type your message" appearing in
three branches) were deduped onto one shared key each — 28 unique strings, not
41, for that file specifically.

### Confidence

Machine-translated without a native-speaker review, same disclaimer as the
`ripple` pass above. Graded per language, not per string — a language's tier
here reflects general confidence in that language's whole batch, illustrated
with the `get_started_button` string ("Get Started").

#### Needs a native speaker (5)

| Lang | `get_started_button` | Note |
|---|---|---|
| `am` | ጀምር | same caution as the `ripple` grading — Ethiopic script, no native check |
| `bo` | འགོ་འཛུགས། | Tibetan; UI register for a whole 41-string batch is a bigger surface than one word |
| `ha` | Fara | Hausa; verify diacritics (ƙ/ɗ/ʼ) rendered correctly throughout |
| `si` | ආරම්භ කරන්න | Sinhala; long compound strings (bullet points) are riskier than single words |
| `zu` | Qala | Zulu; noun-class agreement across 28 Welcome-screen strings not verified |

#### Correct sense, confirm register (15)

| Lang | `get_started_button` | Note |
|---|---|---|
| `be` | Пачаць | Belarusian |
| `bn` | শুরু করুন | Bengali |
| `eu` | Hasi | Basque |
| `fil` | Simulan | Filipino |
| `ga` | Tosaigh | Irish |
| `gu` | શરૂ કરો | Gujarati |
| `kn` | ಪ್ರಾರಂಭಿಸಿ | Kannada |
| `mn` | Эхлэх | Mongolian |
| `ne` | सुरु गरौं | Nepali |
| `pa` | ਸ਼ੁਰੂ ਕਰੋ | Punjabi |
| `sw` | Anza | Swahili |
| `ta` | தொடங்குங்கள் | Tamil |
| `te` | ప్రారంభించండి | Telugu |
| `th` | เริ่มต้นใช้งาน | Thai |
| `uz` | Boshlash | Uzbek |

#### Confident (34)

| Lang | `get_started_button` | Note |
|---|---|---|
| `af` | Begin | |
| `ar` | ابدأ | |
| `ca` | Comença | |
| `cs` | Začít | |
| `da` | Kom i gang | |
| `de` | Los geht's | |
| `el` | Ξεκινήστε | |
| `es` | Comenzar | verified live at runtime |
| `fa` | شروع کنید | |
| `fi` | Aloita | |
| `fr` | Commencer | |
| `fr-CA` | Commencer | same as fr where Quebec usage doesn't diverge |
| `he` | בואו נתחיל | |
| `hi` | शुरू करें | |
| `hu` | Kezdés | |
| `id` | Mulai | |
| `it` | Inizia | |
| `ja` | はじめる | |
| `ko` | 시작하기 | |
| `ms` | Mula | |
| `nl` | Aan de slag | |
| `pl` | Rozpocznij | |
| `pt` | Começar | |
| `pt-BR` | Começar | |
| `ro` | Începe | |
| `ru` | Начать | |
| `sk` | Začať | |
| `sv` | Kom igång | |
| `tr` | Başlayın | |
| `uk` | Почати | |
| `ur` | شروع کریں | |
| `vi` | Bắt đầu | |
| `zh-Hans` | 开始使用 | |
| `zh-Hant` | 開始使用 | |

