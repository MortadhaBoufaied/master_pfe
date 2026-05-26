# Accessibility Audit Gate

This gate covers the Flutter app and the Spring/Thymeleaf admin console.

## Automated Checks To Run

| Target | Command | Gate |
|---|---|---|
| Flutter widget semantics smoke | `flutter test` | Must pass. |
| Flutter analyzer baseline | `flutter analyze` | Must trend downward; make blocking once existing analyzer debt is burned down. |
| Web/admin keyboard flow | Browser automation or manual runbook | Login, dashboard, players, payments, activities, chatbot pages must be keyboard reachable. |
| Contrast | Browser/DevTools Lighthouse or axe | WCAG 2.1 AA contrast violations require fix or documented exception. |
| Screen reader labels | Flutter semantics and browser accessibility tree | Controls must have accessible names. |

## Manual Review Checklist

- All icon-only buttons have accessible labels or visible text.
- Form inputs have associated labels.
- Error messages are programmatically near their fields or announced clearly.
- Focus order follows visual order.
- Keyboard users can open/close dialogs and submit/cancel forms.
- Loading, empty, and error states are visible and not color-only.
- Text remains readable at 200% browser zoom and with large mobile font settings.
- Dark mode, where present, meets the same contrast requirements.

## Current Status

The Flutter smoke test is automated and passing. Full WCAG validation still requires browser/device review against running builds, so production sign-off requires a completed checklist with screenshots or exported accessibility reports.

