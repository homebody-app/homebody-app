# Avatar Config Fields

Use `example.json` as a template. See [AVATAR_SETUP.md](../../AVATAR_SETUP.md) for the workflow.

## Top level

| Field | What it does |
|---|---|
| `id` | Matches the filename (`example.json` → `"id": "example"`). |
| `name` | Display name. |
| `model_url` | `http://{server_ip}:9393/models/<filename>.glb` — `{server_ip}` auto-fills at connect time. |
| `scale` | Uniform scale. `1.0` = as-exported. |
| `spawn_position` | `{x, y, z}` in meters, relative to the player's room origin. |
| `self_collision` | Can the avatar's own body parts collide? |
| `arm_rest_lateral` | Degrees the resting arms angle from the body. |
| `sense_zones` | Touch-sensitivity zones. Leave `{}` here, set via `.local.json` (below). |
| `body_profile` | `"male"` or `"female"` — selects which gendered idle/talking/dance recordings play alongside the neutral set (some deform on a body proportioned differently than the recording's source frame). Omit for neutral-only. |

## `voice`

| Field | What it does |
|---|---|
| `voice_model` | xAI/Grok voice name — see [voice list](https://docs.x.ai/developers/model-capabilities/audio/voice#voices). |
| `voice_conversion.enabled` | Voice changer on by default? |
| `personality` | Free text describing who they are and how they talk. Goes straight into the LLM's system prompt. |
| `greeting` | Said on spawn. `{player_name}` is substituted. |
| `idle_phrases` | Said when idle. |
| `on_player_approach` | Said when the player walks up. |

## `shaders.occlusion`

Materials treated as "unlit" for passthrough occlusion — `skip_transparent_materials`
and `skip_name_substrings` (matched against material/mesh names) exclude things
like eyes/hair that render oddly with it applied.

## `face_animation`

Blend-shape facial animation for rigs without jaw/eyelid/pupil bones. Set
`enabled: false` (overall or per `blink`/`gaze`) if unused.

- `mesh_name` — mouth-amplitude/expression shapes.
- `blink.mesh_names` + `close_shape`/`close_scale` — one or more meshes blinking in sync.
- `gaze.left`/`gaze.right` — per-eye `mesh_name` + four directional shape names, tuned by `max_degrees`/`turn_speed`/`return_speed`/`weight_scale`.

**Don't map a `mouth` bone group AND set `face_animation.mouth` for the same avatar** —
both drive the jaw independently and will fight each other. Pick one: a real jaw bone
(map `mouth` in `bone_groups`), or blendshapes (`face_animation.mouth`, no `mouth`
bone group at all).

`mouth.amplitude_weight_scale` (default `20`) needs per-model tuning — it's a raw
multiplier on top of an already-normalized 0–1 speech amplitude, and the right value
depends entirely on how far your model's own blend shape travels per unit of weight.
The default can overshoot badly on some meshes; if the jaw looks like it's snapping
wide open, try a much smaller value (e.g. `5`–`10`) and adjust from there.

## `bone_groups`

Maps fixed group names (`head`, `left_hand`, `chest`, etc.) to *your* model's
actual bone names. `primary` is the driven bone, `coupled` are bones that move
with it, `passive` (a few groups only) follow without being directly driven.

This is the hard part — see AVATAR_SETUP.md's rigging-mode instructions rather
than hand-filling this. A full rig also needs finger groups
(`left_thumb_root`/`_mid`/`_tip`, etc., both hands) in the same shape.

## `touch_only` / `animation_only` / `posing_only`

Which bone groups are touch-but-not-grabbable / animation-driven-only /
posable-in-learning-mode-only.

## `hand_groups`

Which groups count as hands (usually `["left_hand", "right_hand"]`).

## `face_pose_grab`

Maps groups to a pose-grab kind (`eye`/`jaw`) for learning mode.

## `jiggle`

Secondary jiggle physics. Each entry has a `root` and either `leaves` or
`targets` (`{parent, root}` pairs, e.g. hair strands). Leave `{}` if unused.

## `sense_score_fx`

Sound cues triggered as the avatar's touch/attention "sense score" crosses
thresholds. Array of `{min, max, files}` bands — when the score lands in a
band's range, a random file from `files` plays. Files are served from
`resources/effects/`. Omit this field to get a generic three-tier chime default.

## `soundboard`

Voice cloning + verbatim clip playback from a folder of pre-recorded audio.
`{"clips_dir": "resources/soundboards/<avatar_id>"}` is the whole config — no
per-clip JSON needed. Any `.mp3`/`.wav` dropped in that folder becomes a clip,
named after its filename (minus extension); every clip filename doubles as its
own transcript, so name files after the exact line they say (e.g.
`"Ah, Shit!.mp3"`).

Two things happen automatically once a `soundboard` key with real clips in
`clips_dir` is present:

- Every line the avatar speaks is voice-cloned to sound like the soundboard's
  own voice — a cheap side-model picks whichever clip best fits each turn's
  tone as the cloning reference. No manual toggle; a non-empty clips folder
  turns this on.
- The avatar can splice a clip's audio in verbatim mid-response with an inline
  `<sound:clip_name>` tag (e.g. a laugh, a catchphrase) — it discovers valid
  names via its own `list_soundboard` tool call.

Omit `soundboard` entirely for a normal stock-voice avatar. See
`OPENROUTER_SOUNDBOARD_CLONE_MODEL` in `.env.example` to change the cloning model.

## Local overlays

`<avatar_id>.local.json` (gitignored) deep-merges over the base file at load
time — for real `sense_zones`, or `voice.personality_append` (appended, not
replacing, `voice.personality`). `resources/player.local.json` does the same
for `resources/player.json`.
