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

## Known gap: hardcoded English in the UI

Separate from the above, and still outstanding. Some user-facing strings are
English literals in Swift rather than `LocalizationManager` lookups, so they stay
English in all 54 non-English locales:

- `OptionsMenuSheet.swift` — the Theme and Display sections: **Theme**,
  **Random Theme (Daily)**, **Current Theme:**, **Appearance**, **Text Rotation**,
  **Serif Font**, **Letter Spacing**, **Max Lines**
  (`Text("Aa")` is a font sample, not a translatable string.)
- `WelcomeView.swift` — essentially the whole first-run screen, including the
  title, feature list, and the Get Started button.

The Animation and Actions sections *are* localized, which is why the mismatch is
visible: a Spanish user sees "Ondular" and "Temblar" directly above an English
"Theme" and "Random Theme (Daily)".

Closing this means adding roughly 18 keys across 55 files (~990 strings), so it is
worth doing as its own pass rather than folding into a bug fix.

