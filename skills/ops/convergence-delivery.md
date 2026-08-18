# Convergence and Delivery Contract

> Thin contract for stopping criteria, Evidence promotion, and delivery depth.
> This is **not** a second workflow or state machine. Existing routing, scope, case, analysis, and review contracts remain authoritative.

## 1. Progress means decision delta

A tool call or newly recorded Evidence item is **not** progress by itself.

Count progress only when at least one `decision_delta` occurs:

- a hypothesis is confirmed or rejected;
- a Finding is created, promoted, rejected, or closed;
- a Path gains or closes a material step;
- meaningful coverage is closed;
- scope is narrowed;
- a blocking prerequisite is resolved.

Three consecutive analysis actions with no `decision_delta`, or two stage switches with no `decision_delta`, MUST trigger R43 replan under the existing feasibility gate.

Repeated observations that do not change the decision state SHOULD be consolidated instead of emitted as new Evidence IDs.

## 2. Raw artifact -> Evidence promotion

Tool stdout, traces, screenshots, dumps, packet captures, decompiler exports, and logs are raw artifacts by default.

Promote an observation to Evidence when it materially supports or changes a hypothesis, Finding, Path, coverage decision, scope decision, or blocker resolution.

One artifact MAY support multiple Evidence records, and one Evidence record MAY summarize multiple related low-level observations when they establish one decision-relevant fact. Preserve the artifact path/hash or reproducible command so the summary remains auditable.

Do not create one Evidence item per function call, address, packet, log line, or retry merely because the observation exists.

## 3. Delivery profiles

Delivery depth controls output obligations only; it MUST NOT weaken authorization, scope, evidence grounding, or analysis-quality gates.

| Profile | Use when | Required delivery |
|---|---|---|
| `inline` | Small bounded analysis, focused audit, single question, read-only diagnosis | Answer the objective with grounded conclusions and only the Evidence needed to support them. No mandatory formal report, diagram, journal write, reference persistence, community prompt, or index mutation. |
| `case` | Multi-step reverse/security work that benefits from persistent case state | Scope + relevant workitems/timeline + promoted Evidence/Findings/Paths. Use non-strict review checkpoints when useful. Formal report is optional unless requested or needed for handoff. |
| `formal` | User explicitly requests a report/archive/handoff, or the task is a full engagement deliverable | Strict review before handoff, formal report, and the applicable Evidence chain. Diagram only when it materially improves communication. Journal/reference/index updates remain conditional on reusable new knowledge. |

Default to the lightest profile that satisfies the user's requested deliverable. Escalating from `inline` to `case` or `formal` requires a concrete need; do not escalate only because another skill exists.

## 4. Conditional completion work

After the technical objective is satisfied:

- **Formal report**: required only for `formal`, or when the user explicitly asks for one.
- **Diagram**: create only when structure/flow is materially clearer visually, or the user asks.
- **field-journal**: write only when the task produced reusable new technique, new failure mode, corrected precedent, or meaningful cross-task lesson.
- **references/**: persist web research only when it adds reusable project knowledge beyond the current answer.
- **indexes/routing**: update only when a persisted artifact or genuinely new routing scenario requires it.
- **community contribution**: offer only when relevant; it is never a completion blocker.

Normal successful reuse of an existing method is not by itself a reason to mutate the journal or indexes.

## 5. Decision-boundary menus

Do not pause after every stage solely to present a menu.

A next-step menu is appropriate when:

- user preference is genuinely required;
- scope would expand;
- an operation is destructive, high-cost, or materially risky;
- two or more mutually exclusive paths are similarly justified;
- the objective is already satisfied and optional follow-up work remains.

Otherwise continue through the already-authorized, technically justified path and report progress without requiring a user selection.

## 6. Compatibility

This contract narrows unnecessary runtime obligations; it does not relax:

- authorization or scope gates;
- Force non-bypassability;
- Evidence grounding for Findings/Paths;
- validated sufficiency rules;
- artifact hash checks when recorded;
- strict review requirements when a formal handoff/archive is actually performed.
