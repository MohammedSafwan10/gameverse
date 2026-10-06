# Discovery Gallery related mockups

Selected direction: 03-discovery-gallery.png (replaces earlier Quiz Show selection).
Generated using the built-in GPT image tool and selected direction as style reference.
All nine images visually inspected. Implementation: `docs/QUIZ_MASTER_REDESIGN.md`.
Illustrative scores, question counts and content are not live values.

## Screen/state inventory

- 04-quiz-setup.png
- 05-quiz-gameplay.png
- 06-correct-answer.png
- 07-wrong-answer.png
- 08-times-up.png
- 09-quiz-result.png
- 10-answer-review.png
- 11-how-to-play.png
- 12-leave-confirmation.png

Setup, active quiz, answer feedback, timeout, results, help and exit reflect existing flows.
Answer review and its results button were subsequently approved and implemented.
Loading, empty and failure states should use the same native panel family;
they do not need separate expensive artwork or new mockup-selection rounds.

## Design contract

Porcelain-white surfaces, cobalt/deep-navy type, orange primary accent, sky-blue
architectural niches, marble plinths, realistic isolated glass/ceramic/gold objects.
Serif display headings and readable sans-serif supporting copy.
Keep numbers, labels, answer buttons and all interaction native in Flutter.
Never use the full mockup as an app background.

Mode screen preserves five categories and its 2x2 plus full-width Technology layout.
Setup selects question count from actual bank length, not the pictured example of 75.
Quiz question timer is 30 seconds. Timeout ends one question, not the full round.
Question progress and timer countdown are distinct; render both from real state.
No difficulty selector, new modes or decorative controls that do nothing.

Gameplay artwork must be category-generic: never expose an unanswered question's
solution. Revised active mockup uses Science flask instead of a Mars illustration.
Answer-feedback mockups can show answer-specific art as a concept, but implementation
should default to shared category art unless matching assets genuinely exist.
Do not fabricate a custom image for every offline question.
Correct/wrong/timeout panels must share stable header, question and option positions.
Any extra help icons appearing in generated feedback references are decorative drift:
do not add a gameplay help action absent from the active screen contract.

On 320x568 reduce decorative hero/niche height first, preserve all options and
primary actions. Check 360x800, 390x844 and 430x932 during implementation.
Long question/answer text and accessibility text scaling may intentionally scroll.
Dialog artwork shrinks before native labels or touch targets.
Quiz results messaging must adapt to accuracy, not praise every result identically.
Keep unfinished exit wording truthful; finished-session statistics stay preserved.

## Targeted corrections

05: removed answer-revealing Mars artwork in active question.
10: fixed contradictory option status: Earth wrong/coral/X; Mars correct/mint/check.
Generated drafts remain outside shipped assets; final project references use corrected images.

## Prompt set

### 04-quiz-setup

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Science quiz setup overlay on softly defocused category screen. White raised rounded dialog, close X top-right, modest realistic blue laboratory flask and gold atom on plinth above heading "SCIENCE", subtitle "Set your quiz length". "QUESTIONS" label and prominent selected "10", horizontal slider with end labels "1" and "75" (illustrative available count). Small rules strip "30 seconds per question" and "Speed + streak bonuses". Full-width cobalt "START QUIZ" button, understated "CANCEL". No difficulty selector, no new mode.

### 05-quiz-gameplay

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Active Science question screen. Top back button, "SCIENCE QUIZ" compact title. Two small white score/streak chips "SCORE 120", "STREAK 3". Horizontal question progress "QUESTION 4 OF 10", timer badge "24s" and fine cobalt countdown track. Central large white question card with small tasteful realistic Mars sphere displayed in a sky-blue niche at top taking no more than 18 percent height. Question "Which planet is known as the Red Planet?" Answers A "Earth", B "Mars", C "Jupiter", D "Venus". Four broad white tactile answer rows with cobalt letter disks and navy sans-serif answer labels, none selected. Bottom quiet hint "Tap an answer to continue". No NEXT button before answering, no pause or help control.

Revision: Edit this exact Quiz Master gameplay mockup. Preserve all typography, score/streak, timer, question, four answer options and overall white/cobalt/orange Discovery Gallery design. Change ONLY the artwork inside the question-card blue niche: remove the Mars globe, replace with tasteful generic Science blue glass flask and a small gold atom sculpture on the same ivory plinth. No planets or labels anywhere in art; it must not reveal the correct answer to the Red Planet question. Also reduce this artwork panel height by about a third, keeping card/question/answers balanced and generous tap targets. No extra buttons. All four answers remain neutral/unselected.

### 06-correct-answer

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Science question after correct answer. Compact header "SCIENCE QUIZ", "QUESTION 4 OF 10", "SCORE 146", "STREAK 4", stopped timer "18s". Question "Which planet is known as the Red Planet?" Answers A "Earth", B "Mars", C "Jupiter", D "Venus". White question card and four tactile answer rows: B Mars softly mint with strong dark green border and check symbol, all others pale neutral disabled. Compact inline feedback panel below "CORRECT!" and "+26 points", explanation "Mars looks red because of iron oxide on its surface." Native readable text, small realistic polished green check medallion, not oversized celebratory hero. Full-width orange "NEXT QUESTION" bottom.

### 07-wrong-answer

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Science question after incorrect answer. Compact header "SCIENCE QUIZ", "QUESTION 4 OF 10", "SCORE 120", "STREAK 0", stopped timer "18s". Question "Which planet is known as the Red Planet?" Answers A "Earth", B "Mars", C "Jupiter", D "Venus". Answer A Earth selected soft coral background dark red outline X; B Mars shown mint with green outline check; C Jupiter and D Venus neutral disabled. Calm inline feedback panel "NOT QUITE", "Correct answer: Mars", explanation "Mars looks red because of iron oxide on its surface." No harsh giant red screen, no embarrassing cartoon. Full-width cobalt "NEXT QUESTION" bottom.

### 08-times-up

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Science question timeout screen. Compact header "SCIENCE QUIZ", "QUESTION 4 OF 10", "SCORE 120", "STREAK 0", timer "0s". Question "Which planet is known as the Red Planet?" Answers A "Earth", B "Mars", C "Jupiter", D "Venus". No selected wrong answer. B Mars highlighted pale mint with dark green check, all other options neutral disabled. Small inline warm apricot feedback card with realistic orange-and-white stopwatch icon, "TIME'S UP", "Correct answer: Mars", concise explanation "Mars looks red because of iron oxide on its surface." Full-width cobalt "NEXT QUESTION" bottom. Timeout is one question state, NOT whole quiz ending.

### 09-quiz-result

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Completed Science quiz results page. Back control top-left, title "QUIZ COMPLETE", subtitle "A brilliant round of discovery". Modest premium gold trophy with cobalt enamel star on marble plinth and few restrained orange/blue confetti flecks above white summary panel. Small "SCIENCE • 10 QUESTIONS" label. Prominent "FINAL SCORE" with "246"; 2x2 smaller stats "CORRECT 8/10", "ACCURACY 80%", "BEST STREAK 4x", "QUESTIONS 10". Large orange "PLAY AGAIN", secondary cobalt "REVIEW ANSWERS", understated navy "BACK TO TOPICS". Review is proposed future enhancement. No invented leaderboard or currency.

### 10-answer-review

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Proposed read-only answer review screen, not live timed question. Top back and title "ANSWER REVIEW", subtitle "Science • 8 of 10 correct". White card "QUESTION 4 OF 10", Question "Which planet is known as the Red Planet?" Answers A "Earth", B "Mars", C "Jupiter", D "Venus". Compact rows display "Your answer: Earth" with coral X and "Correct answer: Mars" mint check, then heading "WHY?" and explanation "Mars looks red because of iron oxide on its surface." Small realistic Mars globe on white plinth in sky-blue niche. Bottom navigation two buttons "PREVIOUS" and "NEXT", quieter "BACK TO RESULTS". No timer, score animation, or answer-selection affordance.

Revision: Edit this exact answer-review mockup, preserve every layout, text, object, color family and control except correct the answer option status colors: row A Earth must be pale coral/red with an X on the right, since user chose Earth incorrectly. Row B Mars must be pale mint/green with a check on the right, because Mars is correct. C Jupiter and D Venus stay neutral white-gray. Keep the separate Your answer Earth red card and Correct answer Mars green card unchanged. No other content or composition changes.

### 11-how-to-play

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: How-to-play support screen. Back top-left, serif cobalt title "HOW TO PLAY", subtitle "A little curiosity goes a long way". Modest realistic open ivory book with cobalt question mark sculpture on marble plinth at top. Three clean white rounded instruction cards with small orange number disks: "1 Choose a topic" / "Explore Science, History, Geography, Mathematics or Technology."; "2 Set your quiz length" / "Choose how many questions to answer."; "3 Pick your answer" / "You have 30 seconds per question. Correct answers earn points, with bonuses for speed and streaks." Bottom full-width cobalt "GOT IT". High readability, no dense huge paragraphs, no fake game modes.

### 12-leave-confirmation

Use case: ui-mockup. Input image is ONLY style reference, not an edit target. Generate one separate portrait mobile screen mockup, 390x844 logical proportions, no device frame, no collage. Same Quiz Master Discovery Gallery family as reference: porcelain white tactile rounded panels, cobalt blue and navy readable typography, vivid orange primary accents, sky-blue architectural niches, realistic small glass/ceramic/gold 3D exhibit assets on marble plinths, restrained soft sunlit shadows. Elegant serif display headings paired with readable sans-serif body text. Clean premium mobile game UI, not cartoon. Keep all text legible, controls complete, spacing compact, no oversized hero wasting answer space. Screen must feel implementable with native Flutter text and isolated art. No crown, no violet theater, no unrelated mode buttons. Example scores only.
Screen contract: Leave quiz confirmation overlay, central white tactile dialog on lightly dimmed gameplay screen, underlying question and answers visible but subdued. Small realistic cobalt doorway with orange curved exit arrow on white marble base. Title "LEAVE THIS QUIZ?", readable copy "This unfinished round will not be saved." Cobalt full-width "KEEP PLAYING" primary, white orange-outline "LEAVE QUIZ" secondary. Both clearly visible, generous spacing. No restart action, no falsely claiming current round saved. No other dialog competing.

