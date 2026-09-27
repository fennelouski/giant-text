# Giant Text release preparation

Current preparation: September 27, 2026. App Store Connect app **6749249135**,
registered bundle **com.fennel.Giant-Text**, team **EJLR2RPSV2**, version **1.0**,
build **2**. GiantText Display is a different listing and does not use this source.

The live inventory at 20:10–20:16 UTC showed iOS, macOS, tvOS and visionOS 1.0
drafts in Prepare for Submission, no selected builds and no review items. This
document supersedes earlier claims that an archive or Xcode Cloud success proved
upload, successful processing, UI verification or submission. Current task
evidence is in `app-store-audit/2026-09-27-release/giant-text` in the parent workspace.

## Processing failure and source changes

Apple's July 21 email reports ITMS-90129: a bundle name or display name was
already taken. It does not identify the field, localization, literal name or
embedded target responsible. Build 2 uses the listing's name, Giant Text, as
the main fallback display name and in all 55 localized InfoPlist.strings files.
The registered bundle identifiers stay unchanged. Successful new processing
must establish whether this resolves the error; a local rename cannot prove it.

Release fixes also preserve the first document for immediate edits, prevent
duplicate initial documents, fix undo history and negative letter spacing,
show save errors, expose an accessible Options button, respect Reduce Motion,
and keep gesture overlays out of the text editor. The external display scene
uses the newest document, observes text edits and preserves negative spacing.
App and widget privacy manifests describe their local preferences/app-group use.

## Validation

`Tools/ReleaseChecks/run.sh` compiles the actual SwiftData model, state and action
sources and runs six headless regression checks. It passed first-launch saving
without duplicates, one and repeated undo, editing after undo, undo after clear,
and negative spacing after state recreation. Its model store is temporary;
preferences changed by the checks are restored. These checks do not launch the
app or validate rendering, gestures, accessibility, widgets or external displays.

Signed iOS, macOS, tvOS and visionOS 1.0 build 2 archives passed strict signature validation.
Each has the expected registered bundle and Giant Text localized display names.
The iOS archive includes both app and widget privacy manifests. The Mac archive
has the app manifest and does not embed the iOS widget. See the current
`archive-verification-final.json` and `status.json` for final archive paths and
source commit. macOS contains both arm64 and x86_64. Local App Store export
failed on missing iOS Distribution signing for iOS/visionOS, Mac App/Installer
Distribution signing for Mac, and a missing tvOS distribution profile.

The initial tvOS and visionOS archive attempts failed because their platform
support was not installed. Official Xcode platform downloads completed and both
subsequent signed archives succeeded.
No Simulator or native UI validation was performed by the packaging agent.

## Listing text

Name: Giant Text. Suggested subtitle: Say it big across the room.
Category: Utilities; optional secondary category: Productivity.

Suggested description, adjusted for each platform's actual supported controls:

> Turn your screen into a large, readable sign. Type a message, finish editing,
> and Giant Text scales the letters to fit the display.
>
> Choose serif or sans-serif text, bold or italic, adjustable letter spacing,
> and up to five lines. Pick from 20 color themes with light and dark variants,
> or let the app choose a daily theme. Optional Bloom, Jitter and Ripple
> animations add movement; Reduce Motion keeps the text still.
>
> Use it for a meeting point, a quick reminder, or a message across a noisy room.
> Your current text and preferences are saved on the device. No developer
> account, advertising or purchase is required.

For iOS only, add the Home Screen widget after its real refresh behavior is
verified. Do not claim the widget ships inside the current macOS, tvOS or
visionOS archives. Do not advertise automatic external-display routing without
testing it; the source contains a secondary window scene, not proof of a working
AirPlay connection flow.

Suggested keywords:
`big,large,sign,banner,message,display,noisy,accessibility,visible,announce,screen`

The tvOS Options menu exposes animation, edit, clear and undo. Its listing must
omit theme selection, font controls and line/spacing controls that the tvOS menu
does not offer. Those controls are present in the iOS, macOS and visionOS menus.

For the initial release, release notes can say "Initial release." Review notes
should explain that no sign-in is required, typing edits the current message,
and the visible Options button controls appearance. iPhone intentionally shows
presentation text sideways inside a portrait-locked interface. tvOS supports
Play/Pause to edit and Menu to open Options; verify with the real remote or
Simulator before claiming the flow was tested.

## Privacy, support and content

- Privacy: https://nathanfennel.com/giant-text/privacy.html
- Support: https://nathanfennel.com/giant-text/support.html
- Marketing: https://nathanfennel.com/giant-text

The app stores text and rich-text data with SwiftData and preferences in
UserDefaults. Its app group `group.com.fennel.Giant-Text` shares content with its
own widget on the same device. There is no developer backend, analytics SDK,
account, ad system or purchase flow in this source. Device backups and deliberate
system sharing or screen mirroring are separate from developer collection, so
avoid absolute claims that typed content can never leave the device.

The manifests declare no tracking or collected data. Required-reason API entries
cover app preferences and app-group preferences. The built encryption exemption
key is false. No app-provided objectionable content, emoji picker, public feed,
chat, gambling or mature material was found. Users can type their own text.
Base age/content-rights declarations on those facts and the actual final binary.

## Remaining release work

1. Check the final archives and distribution signing. Upload build 2 for each
   supported listing platform, wait for processing and inspect any remaining
   ITMS-90129 detail. Preserve the existing registered identifiers/app group.
2. Verify first launch, edit/Done, selection and keyboard, undo/clear, persistence
   after relaunch, options, negative spacing, all line counts, themes, animation
   changes, Reduce Motion, VoiceOver, dark mode and large text on actual app UI.
   Include iPhone portrait/sideways presentation, iPad orientations, Mac window
   resizing, tvOS remote focus and visionOS window/input where supported.
3. Check widget refresh using the same installed build. Exercise external-display
   behavior before advertising it. Keep old user text and preferences intact.
4. Capture current, real platform screenshots after QA. Existing screenshot
   scripts and files are historical aids, not verified output for build 2. Do
   not upload mismatched captures, illustrations or resized device substitutes.
5. Complete each platform's description, support/privacy URLs, age/privacy
   declarations and review instructions. Select the successfully processed new
   build, finish submission and verify Waiting for Review or In Review.

The earlier machine translations still lack a native-speaker review. Do not
present the 55 interface localizations as professionally verified.
