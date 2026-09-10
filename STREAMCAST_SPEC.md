# StreamCast — Full App Spec & Build Plan

> **Client:** Ryan Coley (Real Cash Ent)
> **Platform:** Android (Phase 1), iOS next
> **Tech:** Flutter + GetX + WebView hybrid + Google Cast SDK (Default Media Receiver)
> **Tagline:** _Every Stream. One Screen._

---

## 0. Product Pitch

> `// SIGNAL: PITCH`
> A single feed where YouTube, Twitch, Kick, Vimeo, and Facebook Live content lives together — castable to any TV in one tap, even from platforms like Twitch and Kick that don't natively support casting.

### Core Goal
- Centralized, admin-curated streaming feed (YouTube-style UI)
- Universal casting — including platforms with no native cast support
- Zero-friction onboarding: no sign-up, just a name
- Ad-supported free tier + Premium subscription monetization

### Content Model
- **Not user-generated** — only admins/moderators post links from a dashboard
- Regular users can browse, watch, cast, and comment only

### Monetization
- **Free tier:** timed ads every 3–4 min + reward ads for extended watch/cast
- **Premium:** weekly / monthly / yearly plans — ad-free, unlimited casting

---

## 1. Design Tokens

### 1.1 Primitives — `AppColors`

| Token | Hex | Usage |
|---|---|---|
| `ink` / background | `#0B0E14` | App scaffold background |
| `surfacePanel` | `#12161F` | Cards, panels, bottom nav |
| `surfacePanel2` | `#181D29` | Elevated surface, input fields, sheets |
| `borderLine` | `#232938` | Dividers, card borders, outlines |
| `textPrimary` | `#F2EFE9` | Headings, primary body |
| `textDim` | `#8B93A6` | Metadata, captions, muted |
| `accentSignal` | `#FF6B35` | Brand orange — CTA, live badge, active nav |
| `accentSignalDim` | `#7A3A21` | Pressed / disabled CTA |
| `accentAmber` | `#E8B84B` | Premium tier |
| `accentTeal` | `#3E6259` | Reserved accent |

### 1.2 Semantic Aliases

| Alias | Maps to |
|---|---|
| `bgPrimary` | `#0B0E14` |
| `bgSurface` | `#12161F` |
| `bgSurfaceElevated` | `#181D29` |
| `textHeading` | `#F2EFE9` |
| `textBodyMuted` | `#8B93A6` |
| `ctaDefault` | `#FF6B35` |
| `ctaPressed` | `#7A3A21` |
| `badgeLive` | `#FF6B35` |
| `badgePremium` | `#E8B84B` |

### 1.3 Typography — `AppTextStyles`

| Role | Font | Size | Weight | Transform | Tracking |
|---|---|---|---|---|---|
| Wordmark `STREAMCAST` | Roboto Condensed Bold | 26 | Bold | UPPERCASE | -1% |
| Section header | Roboto Condensed Bold | 19 | Bold | UPPERCASE | 0 |
| Body regular | Inter Regular | 14 | 400 | — | 0 |
| Body medium | Inter Medium | 13 | 500 | — | 0 |
| Caption / metadata | Inter Regular | 11.5 | 400 | — | 0 |
| Mono tag `// signal:live` | JetBrains Mono Regular | 10.5 | 400 | lowercase | +3% |

**Fonts to add:** `Roboto Condensed` (Bold), `JetBrains Mono` (Regular) — via `google_fonts` or bundled ttf. `Inter` already bundled in `assets/fonts/`.

### 1.4 Mono Tag Convention
Every section header is preceded by a small orange monospace label:
`// signal:live` · `// feed:curated` · `// setup 01` · `// up:next` · `// query:results`
`// tier:premium` · `// auto:usage-data` · `// saved:liked` · `// saved:queue`
`// signal:out` · `// remote` · `// direct stream · streamcast relay` · `// kick:offline`
`// role:manager` · `// team:access` · `// display name` · `// tap to choose photo`
`// local profile` · `// cancel anytime · billed month` · `// establishing signal`

### 1.5 Shape & Spacing
- Card radius: `12`
- Button / input radius: `12`
- Bottom sheet radius: `20` (top only)
- Chip radius: `999` (pill)
- Screen horizontal padding: `16`
- Card gap (grid): `12`
- Section vertical gap: `24`

---

## 2. Assets

```
assets/images/
  streamcostcircularsplash.png   → splash wave/rings backdrop
  streamsplash.png               → onboarding hero 1
  streamsplash1.png              → onboarding hero 2
  onboarding.png / 1 / 2         → onboarding banners
assets/icons/
  home.svg  explore.svg  premium.svg  mylibray.svg   → bottom nav
  search.svg  add.svg  play.svg  circle.svg
  net.svg (cast icon)  message.svg
```

---

## 3. Architecture

Existing clean-architecture scaffold is **kept as-is** (structure/formula), only the old food-delivery feature code is removed and replaced with StreamCast features.

```
lib/
  main.dart
  app.dart
  core/
    constants/     app_strings.dart, api_constants.dart
    di/            dependency_injection.dart
    exceptions/    app_exceptions.dart
    routes/        app_routes.dart, app_pages.dart
    services/      api_service.dart, cache_service.dart,
                   connectivity_service.dart, storage_service.dart
    theme/         app_theme.dart              (NEW)
    utils/         app_colors.dart, app_text_styles.dart, app_dimens.dart
    widgets/       (shared: SCButton, MonoTag, SectionHeader, LiveBadge,
                   StreamCard, WordMark, SCBottomNav, SCAppBar)   (NEW)
  features/
    splash/        presentation/
    onboarding/    data/ domain/ presentation/
    home/          data/ domain/ presentation/
    watch/         data/ domain/ presentation/
    cast/          data/ domain/ presentation/
    explore/       data/ domain/ presentation/
    premium/       data/ domain/ presentation/
    library/       data/ domain/ presentation/
    profile/       data/ domain/ presentation/
    add_link/      data/ domain/ presentation/
    creator_studio/data/ domain/ presentation/
```

Each feature follows the same 3-layer formula already used by `home`:

```
data/
  models/          *_model.dart          (fromJson / toJson)
  repositories/    *_repository.dart     (ApiService + CacheService + Connectivity)
domain/
  services/        *_service.dart        (business logic)
presentation/
  controllers/     *_controller.dart     (GetxController)
  widgets/         *.dart                (dumb widgets)
  *_page.dart
```

### 3.1 Data Source Policy (Phase 1)
- **API is hidden/disabled for now.** `ApiConstants` stays in the tree but is unused.
- All feeds come from a **static local mock source**: `lib/core/data/mock_data.dart`
- Repositories read from mock data behind the same interface, so swapping to API later is a one-line change inside the repository.
- User-owned state (name, avatar, history, liked, watch later, premium flag) persists via `StorageService` (SharedPreferences).

### 3.2 Storage Keys
```
sc_user_name          String
sc_user_avatar_path   String
sc_onboarded          bool
sc_is_premium         bool
sc_premium_plan       String    weekly|monthly|yearly
sc_history            List<String>  (video ids)
sc_liked              List<String>
sc_watch_later        List<String>
sc_subscribed         List<String>  (channel names)
sc_feed_links         String (json)  — links added via Add-Link sheet
```

---

## 4. Domain Model

```dart
enum StreamPlatform { youtube, twitch, kick, vimeo, facebook, direct }

enum StreamStatus { live, vod, offline, error }

class StreamItem {
  String   id;
  String   title;
  String   channelName;
  String   channelSubscribers;   // "482K subscribers"
  String   thumbnailUrl;         // network or asset
  String   sourceUrl;            // original link
  StreamPlatform platform;
  StreamStatus   status;
  String?  duration;             // "14:02" for VOD
  int?     viewersLive;          // 184000
  int?     views;                // 2100000
  DateTime? publishedAt;         // "2 days ago"
  bool     isSponsored;
}

class ChatMessage { String user; String text; String time; }
class CommentItem { String user; String text; String time; int likes; String avatarLetter; }
class CastDevice  { String name; String subtitle; CastDeviceType type; }
class PremiumPlan { String id; String label; String price; String period; bool isPopular; }
class TeamMember  { String name; String role; String? avatarUrl; } // manager|moderator
```

---

## 5. Screens (28 states)

### PHASE A — Splash & Onboarding ✅ *(build first)*

#### A1. Splash — `/splash`
- Full-bleed `bgPrimary`
- Center: **concentric wave rings** — 3 rings, orange stroke `accentSignal`, expanding scale `0.85 → 1.25` with fading opacity, staggered delays `0s / 0.9s / 1.8s`, duration ~2.7s, `Curves.easeOut`
- Backdrop asset `assets/images/streamcostcircularsplash.png` layered behind rings with a radial orange glow
- Center content: `● StreamCast` wordmark (orange dot + text), fade+scale in `0.96 → 1.0`, 300ms, cubic `(0.23, 1, 0.32, 1)`
- Subtitle: `Every Stream. One Screen.` — 13px, `textDim`
- Bottom (96px from bottom): 150px progress bar, 3px tall, track `borderLine`, fill `accentSignal`, animates `8% → 100%` over 1.5s linear
- Caption below bar: `// establishing signal` — mono 9.5px uppercase `textDim`
- Auto-advance after **1600ms** → onboarding (or home if `sc_onboarded == true`)

**Dart port of the reference animation:**
- `signal-ring` → `AnimationController` (2700ms, repeat) driving `Transform.scale` + `Opacity` on 3 `Container`s with `BoxDecoration(shape: circle, border: Border.all(color: accentSignal))`
- `signal-glow` → `RadialGradient` overlay, `accentSignal.withValues(alpha: .18) → transparent`
- Progress → separate `AnimationController(1500ms)` on a `FractionallySizedBox`

#### A2. Onboarding — `/onboarding`
- Top app bar: `● StreamCast` wordmark, left aligned
- Hero banner: wave-ring artwork with STREAMCAST wordmark (`streamsplash.png` / `streamsplash1.png`)
- `// setup 01`
- Title: **What should we call you?** — 2 lines, 30px bold
- Body: `Your name is stored on this device only. No email, no password, ever.`
- Input: `Enter your name`, `bgSurfaceElevated`, radius 12, border `borderLine` → `accentSignal` on focus
- CTA `Continue`:
  - **empty** → `ctaPressed` `#7A3A21`, dim text, disabled
  - **error** → input border orange + helper `Please enter a name to continue.` in `accentSignal`
  - **filled** → `ctaDefault` `#FF6B35`, black text, enabled
- On submit → save `sc_user_name`, `sc_onboarded = true` → `/home`

---

### PHASE B — Home
#### B1. Home — `/home`
- App bar: `● StreamCast` · `Add Link +` pill (orange) · search icon · cast icon
- `// signal:live` → **Live Now** + `N channels` on the right
  - Horizontal list of large cards (280×160): thumbnail, `● Live` badge top-left, viewer count bottom-left, title (2 lines), `channel · Platform` meta
- `// feed:curated` → **Recommended**
  - 2-column grid, 12px gap: thumbnail with centered play circle + duration chip bottom-right, title (2 lines), channel, `views · time ago`
  - Every 4th slot = **Sponsored ad card**: `Sponsored` chip, TV icon, `Cast to any TV, ad-free — try StreamCast Premium`, `Ad · 7-day trial` (hidden when premium)
- Bottom nav: Home / Explore / Premium / My Library

#### B2. Home — kid/limited variant
Same layout, different dataset (3 channels live).

---

### PHASE C — Watch
#### C1. Watch — Live — `/watch`
- Player area 16:9: thumbnail + centered play button, back button top-left, cast button top-right
- Progress bar under player, orange fill, right label `// live`
- Title (2 lines, 20px bold), meta `Platform · 184K watching now`, ⋮ menu
- Channel row: avatar, name, `482K subscribers`, `Subscribe` outlined orange button (→ `Subscribed` filled when active)
- Tabs: **Chat** | **Comments** — orange underline on active
- **Chat**: rows of `22:16` (mono, dim) + `username` (orange bold) + message; input `Send a message...` + orange send FAB
- **Comments**: avatar letter circle, `user· 2h`, comment body, `214 likes`; input `Add a comment...`
- `// up:next` → **Recommended** vertical list: 120×68 thumb with Live badge, title, channel, `12.4K watching`; sponsored row interleaved

#### C2. Watch — Channel Offline
Player replaced by centered TV icon + `This channel isn't live right now.` + `// kick:offline`

#### C3. Watch — Direct Cast
Below player: full-width orange **`Cast to TV`** button + caption `// direct stream · streamcast relay`

#### C4. Watch — Stream Error
Player replaced by `Couldn't load this stream` + orange **`Retry`** button

---

### PHASE D — Casting
#### D1. Cast sheet — Searching
Bottom sheet, `// signal:out` + **Cast to device** + ✕. Orange spinner + `Searching for devices...`

#### D2. Cast sheet — Not found
TV icon + `No devices found — make sure your TV is on the same Wi-Fi network.` + outlined **`Search again`**

#### D3. Cast sheet — Device picker
List rows: orange TV icon tile, device name, mono subtitle (`Samsung · AirPlay 2`, `Google Cast`, `Apple TV 4K`), footer link `Don't see your device?`

#### D4. Casting Active
- Top banner (above app bar): `● Casting to **Living Room TV**` + chevron
- Expanded banner (`// remote`): orange pause button, volume icon + slider (value 62), outlined **`Disconnect`**

---

### PHASE E — Explore
#### E1. Explore — `/explore`
- Search field `Search streams, channels, platforms` with leading icon
- Filter chips: `All` `YouTube` `Twitch` `Kick` `Vimeo` `Facebook` — active = orange fill, black text
- `//query:results` → **All Results** + `11 items`
- 2-col grid, same card as Home but with Live badge + play overlay

#### E2. Explore — filtered (e.g. Kick)
Header becomes the platform name; grid shows only that platform's items.

---

### PHASE F — Premium
#### F1. Premium — `/premium`
- `// tier:premium` → **Go Premium** (amber, 28px)
- Sub: `Remove ads, cast without limits, unlock every platform.`
- 3 plan cards: **Weekly $2.99/week** · **Monthly $6.99/month** (amber border + `Most Popular` tab, amber price) · **Yearly $39.99/year**
- Feature list card: ✅ Remove ads · ✅ Unlimited casting · ✅ Priority streams (amber checkboxes)
- `// cancel anytime · billed month`
- Sticky bottom CTA: amber **`Upgrade — Monthly $6.99`**

#### F2. Premium Success — `/premium/success`
Amber ✓ in outlined circle, **You're Premium!**, `Ads are gone, casting is unlimited.`, amber **`Continue`**. No bottom nav.

---

### PHASE G — Library & Profile
#### G1. My Library — `/library`
- Header row: avatar, **Ryan**, `// local profile`, chevron → Edit Profile
- `// auto:usage-data` → **History** — horizontal cards (thumb, title, platform), Live badge where relevant
- `// saved:liked` → **Liked** — horizontal cards
- `// saved:queue` → **Watch Later** — dashed-border empty box `Nothing here yet`

#### G2. Edit Profile — `/profile/edit`
- App bar `‹ Edit Profile`
- Circular avatar with orange camera FAB; `// tap to choose photo` (uses `image_picker`)
- `// display name` + input
- Full-width orange **`Save`**

---

### PHASE H — Content Management
#### H1. Add to Feed — bottom sheet
- `ADD TO FEED` + ✕
- Input `Paste a video link (YouTube, Kick, Vimeo, Twitch...)` → chip below shows detected platform (`no link detected` when empty)
- Inputs: `Title`, `Creator / channel name`
- Helper: _Every link plays inside StreamCast — YouTube and Vimeo embed cleanly, Kick embeds live channels only, Twitch uses its own official player. Direct video files get a Cast-to-TV button; YouTube uses YouTube's own Cast button._
- **`Add to Feed`** button

#### H2. Creator Studio — `/studio`
- `← CREATOR STUDIO`, `// role:manager`
- Card: orange `+` circle, **Add a new link** / `Post a live stream or video to the feed` ›
- `// team:access` → **MANAGE TEAM**
- Manager row: avatar, `Ryan Coley`, orange `MANAGER` pill, orange border card
- `Moderators` — dashed empty box `No moderators yet — add one below`
- Input `Channel / creator name` + orange **`Add`**
- Example row: avatar, `Al Jamil`, `Moderator` chip, ⋮

---

## 6. Bottom Navigation
4 tabs, `bgSurface` `#12161F`, top border `borderLine`, active = `accentSignal`, inactive = `textDim`.

| Index | Label | Icon | Route |
|---|---|---|---|
| 0 | Home | `home.svg` | `/home` |
| 1 | Explore | `explore.svg` | `/explore` |
| 2 | Premium | `premium.svg` | `/premium` |
| 3 | My Library | `mylibray.svg` | `/library` |

---

## 7. Routes

```dart
/splash            SplashPage
/onboarding        OnboardingPage
/main              MainShell (IndexedStack + bottom nav)
/home              HomePage
/explore           ExplorePage
/premium           PremiumPage
/premium/success   PremiumSuccessPage
/library           LibraryPage
/profile/edit      EditProfilePage
/watch             WatchPage          (arguments: StreamItem)
/studio            CreatorStudioPage
// sheets: AddLinkSheet, CastSheet — shown via Get.bottomSheet
```

---

## 8. Live Streaming Test
Test URL kept for the player integration step:
`https://www.youtube.com/watch?v=mKCieTImjvU`

Playback strategy per platform:
| Platform | Method | Cast |
|---|---|---|
| YouTube | YouTube IFrame in WebView | YouTube's own cast button |
| Vimeo | Vimeo embed in WebView | — |
| Kick | Kick embed (live channels only) | StreamCast relay |
| Twitch | Official Twitch player | StreamCast relay |
| Direct file (mp4/m3u8) | Native player | `Cast to TV` (Google Cast Default Media Receiver) |

---

## 9. Build Order (step-by-step)

| Step | Scope | Status |
|---|---|---|
| **0** | Clean old food-delivery code, add theme/tokens/fonts, shared widgets | ✅ |
| **1** | **Splash** (wave rings + progress) + **Onboarding** (name entry, 3 states) | ✅ |
| 2 | MainShell + Bottom nav + Home (live rail, recommended grid, ad card) | 🟡 shell + nav done, Home pending ← _next_ |
| 3 | Watch page (4 states) + Chat/Comments tabs + up-next | ⬜ |
| 4 | Cast sheets (4 states) + casting-active banner | ⬜ |
| 5 | Explore (search + platform filters) | ⬜ |
| 6 | Premium + success | ⬜ |
| 7 | My Library + Edit Profile | ⬜ |
| 8 | Add Link sheet + Creator Studio | ⬜ |
| 9 | Real playback (WebView/YouTube) + Google Cast SDK wiring + ad timers | ⬜ |

**Rule:** all data is static/mock in steps 1–8. API stays hidden. Each step ends with a working build before moving on.
