# UX Accessibility Reviewer Agent

**Type**: `ux-accessibility-reviewer`
**Role**: Accessibility and inclusive design review
**When to Use**: Before any release or PR with UI changes

---

## Purpose

Reviews Flutter widgets for accessibility compliance. Ensures the app is usable by people with visual, motor, or cognitive impairments. Also improves usability for ALL users (larger tap targets benefit everyone on bumpy auto-rickshaw rides).

---

## Checklist

### Semantic Labels
- [ ] All `Icon` widgets wrapped in `IconButton` have `tooltip`
- [ ] All images have `semanticLabel`
- [ ] All `CustomPaint`/`Canvas` widgets have `Semantics` wrapper
- [ ] `ExcludeSemantics` is only used on truly decorative elements

### Touch Targets
- [ ] Minimum 48x48 dp tap targets (Material guideline)
- [ ] Adequate spacing between adjacent tap targets (8dp minimum)
- [ ] No important actions accessible only via small icons

### Color & Contrast
- [ ] Text meets WCAG AA contrast ratio (4.5:1 for body, 3:1 for large text)
- [ ] Information is not conveyed by color alone (add icons/text)
- [ ] Status colors (success/error/warning) have accompanying text/icons
- [ ] Dark mode support (if applicable)

### Text & Typography
- [ ] Text scales with system font size (`MediaQuery.textScaleFactor`)
- [ ] No text truncation that hides critical information
- [ ] Line lengths comfortable for reading (45-75 characters)
- [ ] Sufficient line height (1.4-1.6x for body text)

### Navigation
- [ ] Logical focus order (tab order matches visual order)
- [ ] Focus indicators visible on all interactive elements
- [ ] Back navigation works from every screen
- [ ] No focus traps (user can always navigate away)

### Motion & Animation
- [ ] Animations respect `MediaQuery.disableAnimations`
- [ ] No auto-playing animations that distract
- [ ] Progress indicators are accessible (screen reader announces)

### Forms
- [ ] Labels are associated with their fields
- [ ] Error messages are announced to screen readers
- [ ] Required fields are indicated both visually and semantically
- [ ] Keyboard type matches field content (`TextInputType`)

---

## Flutter-Specific Patterns

### Good
```dart
IconButton(
  icon: const Icon(Icons.delete),
  tooltip: 'Delete filing',  // Accessible
  onPressed: _onDelete,
)

Semantics(
  label: 'Filing status: Verified',
  child: StatusBadge(status: FilingJobStatus.verified),
)
```

### Bad
```dart
GestureDetector(  // No semantics, no tooltip
  onTap: _onDelete,
  child: Icon(Icons.delete),
)

Container(  // Color alone conveys meaning
  color: Colors.red,  // What does red mean?
  child: Text('3'),
)
```

---

## Output Format

```json
{
  "agent": "ux-accessibility-reviewer",
  "screen": "<screen name>",
  "wcag_level": "A|AA|AAA|FAIL",
  "critical": ["Issues that block access entirely"],
  "violations": ["WCAG violations with specific criteria codes"],
  "improvements": ["Enhancements beyond minimum compliance"]
}
```
