# Quiz Master — Discovery Gallery

Direction 3 and its related screens are user-approved, including answer review.
References: `docs/mockups/quiz_master/03-discovery-gallery.png` and 04–12.

Porcelain panels, cobalt/navy serif headings, Barlow body typography, orange
actions, marble and sky-blue exhibit artwork. Text, answers and state stay native.
All five topics and How to Play fit standard 320×568, 360×800, 390×844 and
430×932 viewports. Larger accessibility text and long quiz content may scroll
without truncation; next/finish stays fixed. Generic topic art avoids answer hints.

Flow: topics → quiz-length setup → questions → correct/wrong/timeout feedback
→ results → read-only review, replay or topics. Help and leave share the theme.
Existing local stats remain compatible. No new difficulty selector: the existing
offline banks contain mixed question difficulties.

Logic fixes: no artificial loading delay; safe empty/unknown topics; validated
payloads and duplicate IDs; stale-load guards; repeated/invalid/paused/late input
rejection; elapsed active-time countdown; background/leave pause; early completion
rejection; once-per-completed-session saving. Review preserves chosen answers,
timeouts, points and explanations. Save errors surfaced by the saver are retryable.

Ten generated assets are declared explicitly. Prompts and font license are in
`docs/mockups/quiz_master/ARTWORK.md`. No audio changes. Decode widths are bounded.

Verification: 60 focused checks passed, including 40 screen/state renders at
four sizes, large text, timer, scoring and all five question banks. Asset loading
is explicitly asserted. Analysis clean; Android debug build successful.
Full serial suite: 382 passed, 9 existing unrelated golden differences (Memory
Match 4, Flappy Bird 2, utility screens 3). Baselines left untouched.
Structural bank checks are not a factual audit of every question or a guarantee
of no bugs. Temporary renders are `.dart_tool` files, not committed baselines.

Next app-wide redesign: Games/category catalogue. Preserve unrelated changes
and generated desktop registrants when committing this work.
