# ClaudeKit Landing Page - AI Context File

## Project Overview

**ClaudeKit** is a complete AI development team-in-a-box with 15 specialized agents that work like real developers—planning, researching, designing, coding, testing, reviewing, and deploying features. Built on Claude Code by Anthropic.

This repository contains the **marketing landing page** for ClaudeKit Engineer, designed to convert visitors into customers by demonstrating the value proposition: "Stop buying dead boilerplate code. Get a living AI development team instead."

### Core Value Propositions
- **NOT a boilerplate**: Living AI agent system that evolves (vs. frozen dead code)
- **ANY tech stack**: Works with Next.js, Nuxt, Django, Laravel, Go, Rust, etc. (vs. locked choices)
- **Production-tested**: Built by 18+ year CTO who burned millions of Claude tokens
- **$99 one-time payment**: Breaks even on first feature (saves 10+ hours minimum)
- **UNIQUE DIFFERENTIATOR**: AI-generated visual assets (wallets, cards, illustrations) that no other tool can create

---

## Tech Stack

### Frontend Framework
- **Next.js 14+** with App Router (React 18+)
- **TypeScript** for type safety
- Server-Side Rendering (SSR) for SEO optimization
- Static Site Generation (SSG) where possible for performance

### Styling & UI
- **Tailwind CSS** for utility-first styling
- **shadcn/ui** for accessible UI components
- **Radix UI** primitives for headless components
- Custom design system with ClaudeKit brand colors and typography
- Responsive design (mobile-first approach)
- Dark mode support (optional but recommended)

### Performance & SEO
- **Next.js Image Optimization** for all images
- **next-seo** for meta tags and Open Graph
- **Lighthouse Score Target**: 95+ on all metrics
- **Core Web Vitals**: LCP < 2.5s, FID < 100ms, CLS < 0.1
- **Vercel Analytics** (or similar) for performance monitoring

### Forms & Payments
- **React Hook Form** for form validation
- **Stripe Checkout** for payment processing ($99 one-time payment)
- **Gumroad** (alternative payment processor mentioned on site)
- Email capture for waitlist (Marketing Kit waitlist)

### Backend & Data
- **API Routes** (Next.js) for server-side logic
- **MongoDB** or **PostgreSQL** for customer database (inferred from product features)
- **Resend** or **SendGrid** for transactional emails
- **GitHub OAuth** for repository access provisioning

### Deployment & Infrastructure
- **Vercel** (primary hosting platform)
- **Cloudflare** for CDN and edge caching
- **GitHub Actions** for CI/CD
- **Sentry** for error monitoring (recommended)

### Analytics & Marketing
- **Plausible** or **Fathom Analytics** (privacy-friendly)
- **ConvertKit** for email sequences
- **Referral tracking system** (20% recurring commission)
- **Testimonial widgets** (Discord, X.com, Facebook comments)

---

## Project Structure

```
claudekit-landing-page/
├── .claude/                    # AI agent configuration (if using ClaudeKit dogfooding)
│   ├── agents/                # 15 specialized agents
│   ├── commands/              # Slash commands for workflows
│   └── skills/                # 34 pre-built agent skills
├── app/                       # Next.js App Router
│   ├── (marketing)/           # Marketing pages group
│   │   ├── page.tsx          # Homepage (main landing page)
│   │   ├── features/         # Features section (15 agents detail)
│   │   ├── pricing/          # Pricing page ($99 one-time)
│   │   ├── docs/             # Documentation portal
│   │   └── changelog/        # Product updates
│   ├── api/                  # API routes
│   │   ├── checkout/         # Stripe payment endpoints
│   │   ├── referral/         # Referral tracking
│   │   └── webhooks/         # Stripe webhooks
│   ├── layout.tsx            # Root layout
│   └── globals.css           # Global styles
├── components/               # React components
│   ├── ui/                   # shadcn/ui components
│   ├── sections/             # Landing page sections
│   │   ├── Hero.tsx         # Hero section with CTA
│   │   ├── ProblemStatement.tsx  # "Traditional Boilerplates Are Dead"
│   │   ├── Solution.tsx     # "Introducing ClaudeKit"
│   │   ├── AgentShowcase.tsx     # 15 agents with examples
│   │   ├── BootstrapDemo.tsx     # Screenshot-to-code demo
│   │   ├── Comparison.tsx   # Dead code vs Living agents table
│   │   ├── Pricing.tsx      # Pricing card ($99)
│   │   ├── Testimonials.tsx # Social proof (Discord, X.com)
│   │   ├── FAQ.tsx          # Frequently asked questions
│   │   └── CTA.tsx          # Final call-to-action
│   ├── AgentCard.tsx        # Individual agent display card
│   ├── FeatureGrid.tsx      # Feature comparison grid
│   └── VideoDemo.tsx        # Video player for demo
├── lib/                     # Utility functions
│   ├── stripe.ts           # Stripe configuration
│   ├── analytics.ts        # Analytics helpers
│   └── db.ts               # Database connection
├── public/                 # Static assets
│   ├── images/             # Product screenshots, logos
│   ├── videos/             # Demo videos
│   └── testimonials/       # Social proof images
├── content/                # Markdown content (optional)
│   ├── agents/             # Agent descriptions (15 files)
│   ├── skills/             # Skill descriptions (34 files)
│   └── faq/                # FAQ entries
├── types/                  # TypeScript types
├── styles/                 # Additional stylesheets
├── .env.local              # Environment variables (secrets)
├── .env.example            # Example environment variables
├── CLAUDE.md               # This file (AI context)
├── README.md               # Development instructions
├── package.json            # Dependencies
└── tailwind.config.ts      # Tailwind configuration
```

---

## Code Standards & Conventions

### TypeScript Guidelines
- **Strict mode enabled**: `"strict": true` in tsconfig.json
- Use explicit types, avoid `any`
- Export types from component files for reusability
- Use type inference where obvious (e.g., `const count = 0` instead of `const count: number = 0`)

### React Components
- **Server Components by default** (Next.js 14 App Router)
- Use `'use client'` directive only when necessary (interactivity, hooks, browser APIs)
- Functional components with TypeScript interfaces for props
- Component naming: `PascalCase.tsx` (e.g., `AgentCard.tsx`)
- Export components as named exports, not default (better for refactoring)

```typescript
// ✅ Good
export function AgentCard({ agent }: AgentCardProps) {
  return <div>...</div>
}

// ❌ Bad
export default function AgentCard(props: any) {
  return <div>...</div>
}
```

### Styling
- **Tailwind CSS utility classes** as primary styling method
- Use `clsx` or `cn()` helper for conditional classes
- Component-specific styles only when Tailwind is insufficient
- Mobile-first responsive design: `md:`, `lg:`, `xl:` breakpoints
- Consistent spacing scale: `space-y-4`, `gap-6`, `p-8`, etc.

### Performance Best Practices
- Use `next/image` for ALL images (automatic optimization)
- Lazy load components below the fold with `React.lazy()` or `next/dynamic`
- Minimize JavaScript bundle size (code splitting)
- Prefetch critical navigation links with `<Link prefetch>`
- Optimize fonts with `next/font`

### SEO Requirements
- Every page must have unique `<title>` and `<meta name="description">`
- Open Graph tags for social sharing (og:image, og:title, og:description)
- Structured data (JSON-LD) for rich snippets
- Semantic HTML: `<header>`, `<nav>`, `<main>`, `<section>`, `<footer>`
- Accessibility: ARIA labels, alt text for images, keyboard navigation

---

## Key Features & Content Sections

### 1. Hero Section
- **Headline**: "Get an Multi-Agent AI Team That Ships Production Code in Hours"
- **Subheadline**: Emphasize battle-tested by 18+ year CTO, zero lock-in, works with any stack
- **CTA Button**: "Get ClaudeKit - $99" (Stripe checkout link)
- **Social Proof**: "Join 316+ happy builders using ClaudeKit"
- **Trust Badges**: "Built on Claude Code by Anthropic", "15 specialized AI agents cover entire SDLC"

### 2. Problem Statement ("Traditional Boilerplates Are Dead Code")
- Pain points experienced developers face:
  - ❌ Locked into their tech stack
  - ❌ Outdated dependencies within weeks
  - ❌ Doesn't fit your use case
  - ❌ Learning curve steeper than building from scratch
  - ❌ Zero support after purchase
- Contrast with what developers actually need (✓ checklist)

### 3. Solution ("Introducing ClaudeKit")
- **3 Core Differentiators**:
  1. 🧬 **Living System, Not Dead Code**: Agents evolve with Claude improvements
  2. 🎯 **Works With ANY Tech Stack**: Learn YOUR patterns via CLAUDE.md
  3. ⚡ **Proven in Production**: Battle-tested by 18+ year CTO

### 4. Demo Section ("See ClaudeKit in Action")
- **Video embed**: Screen recording of feature implementation
- **Screenshot transformation**: Before/After comparison
  - Before: Basic settings UI without custom graphics
  - After: Production-ready code with AI-generated wallet/card assets
- **CRITICAL DIFFERENTIATOR**: AI-generated visual assets that Cursor, Windsurf, Aider, Cline cannot do

### 5. Agent Showcase (15 Specialized Agents)
- Each agent displayed as expandable card:
  - Icon/emoji identifier
  - Agent name (e.g., "planner", "tester", "ui-ux-designer")
  - Brief description (1-2 sentences)
  - "Show Example" button (modal or accordion)
- Agents:
  1. planner — Planning & Research Coordination
  2. researcher — Parallel Research & Best Practices
  3. ui-ux-designer — Screenshot-to-code + AI visual assets
  4. database-admin — Schema Design & Migrations
  5. tester — Comprehensive Test Suite Generation
  6. code-reviewer — Quality Assurance & Security Audits
  7. debugger — Log Analysis & Root Cause Identification
  8. docs-manager — Auto-Updating Documentation
  9. git-manager — Professional Commits & PRs
  10. project-manager — Progress Tracking & Roadmaps
  11. copywriter — Marketing Copy & Changelogs
  12. journal-writer — Development Journals & Decision Logs
  13. brainstormer — Creative Brainstorming & Ideation
  14. scout — Codebase Exploration & Discovery
  15. scout-external — External Tools Integration

### 6. Agent Workflow Visualization
- **Diagram/Animation showing**:
  - Sequential Chain Workflow
  - Parallel Execution Workflow
  - Query Fan-Out Workflow

### 7. Skills Showcase (34 Pre-Built Skills)
- Tabbed interface with categories:
  - Development (10): Next.js, Better Auth, shadcn/ui, Tailwind, Turborepo, MCP Builder, PostgreSQL, MongoDB, Repomix, Skill Creator
  - Creative (3)
  - Cloud & Edge (4): Cloudflare Workers/R2/D1, Docker, Google Cloud
  - Enterprise (5)
  - AI & Media (7): Gemini AI, FFmpeg
  - Document (1)
  - Utilities (4)

### 8. Repository Structure Preview ("See Exactly What You're Getting")
- File tree visualization (expandable/collapsible)
- 4 key areas highlighted:
  1. 15 AI Agent Instructions
  2. 35+ Custom Slash Commands
  3. CLAUDE.md Template
  4. Documentation System
- "Full transparency" messaging

### 9. CLI Installation ("Get Started in Seconds")
- Terminal code snippet with syntax highlighting:
  ```bash
  bun add -g claudekit-cli
  ck new --dir my-project --kit engineer
  ck update --kit engineer
  ```
- Benefits: Bootstrap in seconds, seamless updates, smart protection, GitHub auth

### 10. Comparison Table ("Dead Boilerplate vs Living AI Team")
- 12 comparison criteria (rows)
- 2 columns: Traditional Boilerplates vs ClaudeKit Engineer
- Emphasize fundamental difference in philosophy

### 11. Pricing Section
- **Single card**: ClaudeKit Engineer - $99 (was $149)
- **ROI Calculator**:
  - Time saved: 10 hours minimum
  - Your rate: $100/hour (conservative)
  - Value created: $1,000
  - Investment: $99
  - Net profit: $901
- **What's Included** (expandable checklist):
  - 15 specialized AI agents
  - 34 pre-built agent skills
  - Production-ready workflows
  - Flexibility & Freedom
- **CTA**: "Get ClaudeKit - $99"
- **Guarantee**: 💯 30-Day Money-Back Guarantee

### 12. Founder Story ("Why I Built ClaudeKit")
- Photo of Goon Nguyen
- Brief bio: "18+ years as CTO"
- Personal narrative about burning millions of Claude tokens
- Social links: Facebook, X (Twitter), GitHub

### 13. Testimonials (Social Proof)
- Real quotes from Discord, X.com, Facebook
- Mix of formats: screenshots, embedded tweets, text quotes
- Names: Hoan Nguyen, Philonik, Lương Thanh Thế, Zachary Nguyen, cesc, LAM (@laingoclam), Hải Đăng, Mr The, Florin Makes

### 14. FAQ Section (Accordion)
- 10 questions:
  1. Why choose ClaudeKit over traditional boilerplates?
  2. What tech stacks does ClaudeKit Engineer support?
  3. Do I need to know how to use Claude Code?
  4. What's included in the $99?
  5. Is there a money-back guarantee?
  6. Do the agents work with my existing codebase?
  7. What if Claude Code updates or changes?
  8. What happens after I purchase?
  9. Should I try Claude Code first before buying?
  10. How is ClaudeKit different from OpenSpec/SpecKit?

### 15. Referral Program CTA
- "Turn ClaudeKit Into Passive Income"
- 20% recurring commission
- Examples: $19.80 per referral, $198 with 10, $1,980 with 100
- "Get Your Referral Link" button

### 16. Footer
- **Product**: Features, Pricing, Documentation, Changelog
- **Resources**: Blog, Guides, Examples, API Reference
- **Community**: Discord, GitHub
- **Company**: About, Referral Program, Contact, Privacy, Terms
- **Trust Badges**: 🔒 Stripe Verified | SOC 2 Certified | GDPR Compliant
- **Copyright**: © 2025 ClaudeKit. Built on Claude Code by Anthropic.

---

## Content Writing Guidelines

### Tone & Voice
- **Conversational but professional**: Speak directly to experienced developers
- **No BS marketing fluff**: Developers smell fake enthusiasm from miles away
- **Problem-aware**: Acknowledge real pain points (outdated deps, tech lock-in, learning curves)
- **Confident but not arrogant**: "Battle-tested" not "revolutionary" or "cutting-edge"
- **ROI-focused**: Always tie features back to time/money saved

### Copy Patterns
- **Use contrasts**: "Not X. Y instead." (e.g., "Not a template. Not a boilerplate. Not dead code.")
- **Checkmarks for benefits**: ✓ Always use checkmarks for positive statements
- **X marks for pain points**: ❌ Use X marks for problems/negatives
- **Social proof numbers**: "Join 316+ happy builders" (update dynamically)
- **Specific examples**: "Next.js 16 breaks everything" not "framework updates cause issues"

### CTAs (Call-to-Action)
- **Primary CTA**: "Get ClaudeKit - $99" (must appear 6+ times on page)
- **Secondary CTA**: "See How the 15 Agents Work ↓"
- **Tertiary CTAs**: "View Full Documentation →", "Get Your Referral Link →"
- **Guarantee**: Always pair pricing CTAs with "30-day money-back guarantee"

### Prohibited Language
- ❌ No "revolutionary", "game-changing", "disruptive" (overused marketing buzzwords)
- ❌ No "AI-powered" without specifics (say "15 specialized AI agents" instead)
- ❌ No "10x faster" claims without proof (use "saves 10+ hours per feature" with ROI calc)
- ❌ No "world's first" or "only" claims (except for AI-generated visual assets differentiator)

---

## Testing Requirements

### Unit Tests
- Test all utility functions in `lib/` directory
- Test form validation logic (email capture, Stripe integration)
- Test analytics tracking functions
- **Coverage target**: 80%+ for business logic

### Integration Tests
- Stripe payment flow (checkout, webhooks, success/failure states)
- Referral tracking system (link generation, commission calculation)
- Email capture and drip campaign triggers
- GitHub repository access provisioning

### E2E Tests (Playwright or Cypress)
- **Critical User Journeys**:
  1. Homepage → Pricing → Checkout → Success (purchase flow)
  2. Homepage → Features → Agent Details (product discovery)
  3. Referral link generation and tracking
  4. FAQ accordion functionality
  5. Video/demo interactions
- **Mobile responsiveness**: Test on iPhone, iPad, Android viewports
- **Performance**: Lighthouse CI in GitHub Actions (fail if score < 90)

### Visual Regression Tests
- Screenshot comparison for key sections (Hero, Pricing, Agent Cards)
- Test across breakpoints: mobile (375px), tablet (768px), desktop (1440px)

---

## Deployment & CI/CD

### Environments
- **Production**: `claudekit.com` (or actual domain)
- **Staging**: `staging.claudekit.com` (for testing before production)
- **Preview**: Vercel auto-generates preview URLs for PRs

### Deployment Workflow
1. **Developer pushes to branch** → Vercel creates preview deployment
2. **PR approved & merged to `main`** → Auto-deploy to staging
3. **Manual promotion** (or scheduled) → Deploy staging to production
4. **Post-deployment checks**: Smoke tests, analytics verification

### Environment Variables
```bash
# Stripe (payment processing)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_xxx
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# Database
DATABASE_URL=postgresql://xxx

# Analytics
NEXT_PUBLIC_ANALYTICS_ID=xxx

# Email (transactional)
RESEND_API_KEY=re_xxx

# GitHub (repository access)
GITHUB_APP_ID=xxx
GITHUB_PRIVATE_KEY=xxx

# Referral tracking
REWARDFUL_API_KEY=xxx (or custom solution)
```

### Monitoring
- **Error tracking**: Sentry (or similar)
- **Performance**: Vercel Analytics + Lighthouse CI
- **Uptime**: UptimeRobot or Pingdom
- **Conversion funnel**: Google Analytics 4 or Plausible + custom events

---

## AI Agent Instructions

### When Working on This Project

#### For UI/UX Changes
- **Always maintain mobile-first responsive design**
- Use Tailwind CSS classes (avoid custom CSS unless absolutely necessary)
- Ensure accessibility (ARIA labels, keyboard navigation, alt text)
- Test on multiple viewports: 375px (mobile), 768px (tablet), 1440px (desktop)
- Optimize images with `next/image` (width, height, alt required)

#### For Content/Copy Changes
- **Match existing tone**: Conversational, problem-aware, ROI-focused
- Use specific examples: "Next.js 16 breaks everything" not "framework issues"
- Always tie features to outcomes: "saves 10+ hours" not "improves productivity"
- Update social proof numbers dynamically (e.g., "Join 316+ builders" should pull from database)
- No marketing fluff: avoid "revolutionary", "game-changing", "cutting-edge"

#### For Performance Optimization
- **Target Lighthouse scores**: 95+ on all metrics
- Lazy load below-the-fold components
- Code split heavy sections (Agent Showcase, Testimonials)
- Optimize video embeds (use `loading="lazy"`, YouTube iframe API)
- Minimize JavaScript bundle (analyze with `next bundle-analyzer`)

#### For New Features
1. **Plan first**: Use `/plan` command to create detailed implementation plan
2. **Test during development**: Write tests alongside code (TDD when possible)
3. **Document changes**: Update this CLAUDE.md if adding new patterns/conventions
4. **Review before PR**: Use `/review` command for automated code review
5. **Performance check**: Run Lighthouse CI before merging

#### For Bug Fixes
1. **Reproduce first**: Understand exact conditions causing the bug
2. **Root cause analysis**: Use debugger agent patterns (log analysis, trace inspection)
3. **Write regression test**: Ensure bug doesn't reoccur
4. **Document in changelog**: Add entry to changelog page if user-facing

### File Boundaries & Restrictions
- **Never modify**: `.env.local` (contains secrets, each developer has their own)
- **Always update**: `.env.example` when adding new environment variables
- **Protect user data**: No customer PII in logs, error messages, or analytics
- **Git hygiene**: No AI attribution in commit messages (e.g., "Implemented by Claude" ❌)

---

## Marketing & Conversion Optimization

### Key Conversion Metrics
- **Primary goal**: Click "Get ClaudeKit - $99" CTA → Complete Stripe checkout
- **Secondary goals**:
  - Email capture (waitlist for Marketing Kit)
  - Referral link generation
  - Documentation clicks (indicates serious interest)
  - Video demo views (engagement indicator)

### A/B Testing Opportunities
- Hero headline variations ("Multi-Agent AI Team" vs "15 AI Developers")
- Pricing display (crossed-out $149 vs no anchor)
- CTA button copy ("Get ClaudeKit" vs "Start Building" vs "Download Now")
- Testimonial placement (above vs below pricing)
- ROI calculator (static vs interactive)

### SEO Keywords (Primary)
- "AI coding assistant"
- "AI development team"
- "Claude Code agents"
- "boilerplate alternative"
- "AI code generation"

### SEO Keywords (Long-tail)
- "AI tool that generates visual assets"
- "screenshot to code with AI"
- "AI agents for software development"
- "alternative to Cursor and Windsurf"
- "production-ready AI coding tool"

---

## Changelog & Version History

### Version 1.0.0 (Initial Launch)
- 15 specialized AI agents
- 34 pre-built agent skills
- 35+ custom slash commands
- $99 one-time pricing
- 30-day money-back guarantee
- Referral program (20% commission)

### Future Roadmap (Mentioned on Landing Page)
- **ClaudeKit Marketing** (Coming Q2 2025): Copywriting, SEO, ads, email sequences
- **ClaudeKit Combo** (Coming Q2 2025): Engineer + Marketing at 25% discount

---

## Support & Community

### Support Channels
- **GitHub Issues**: Bug reports and feature requests
- **Discord**: Community support (mentioned in testimonials)
- **Email**: support@claudekit.com (for customers)
- **Documentation**: docs.claudekit.com

### Community Guidelines
- Be helpful and respectful
- No spam or self-promotion (unless in designated channels)
- Share real experiences and use cases
- Provide constructive feedback

---

## Legal & Compliance

### Privacy & Data Protection
- **GDPR compliant**: Cookie consent, data export, right to deletion
- **No personal data in analytics**: Use privacy-friendly tools (Plausible/Fathom)
- **Stripe handles payment data**: No credit card numbers stored in our database

### Terms of Service
- One-time payment ($99)
- Lifetime access to ClaudeKit Engineer repository
- All future updates included (no subscription)
- 30-day money-back guarantee (no questions asked)
- No refunds after 30 days

### License
- **Product**: Proprietary (private GitHub repository access)
- **Landing page code**: Keep private (contains business logic, Stripe keys)

---

## Quick Reference

### Most Common Commands
```bash
# Development
npm run dev              # Start development server
npm run build            # Build for production
npm run start            # Start production server
npm run lint             # Run ESLint
npm run type-check       # Run TypeScript compiler

# Testing
npm run test             # Run unit tests
npm run test:e2e         # Run E2E tests (Playwright)
npm run test:coverage    # Generate coverage report

# Deployment
vercel                   # Deploy to Vercel
vercel --prod            # Deploy to production

# Database
npm run db:migrate       # Run database migrations
npm run db:seed          # Seed database with test data
```

### Emergency Contacts
- **CTO/Founder**: Goon Nguyen (GitHub: @goon, X: @GoonNguyen)
- **On-call**: [Rotation schedule]
- **Stripe Support**: support@stripe.com (for payment issues)

### Critical Links
- **Production**: https://claudekit.com
- **Staging**: https://staging.claudekit.com
- **GitHub Repo**: https://github.com/claudekit/claudekit-landing
- **Design Figma**: [Link to Figma file]
- **Analytics Dashboard**: [Link to analytics]
- **Error Monitoring**: [Link to Sentry]

---

**Last Updated**: 2025-11-06
**Maintained By**: ClaudeKit Engineering Team
**AI Context Version**: 1.0.0

---

_This CLAUDE.md file is optimized for AI agents (Claude Code, ClaudeKit Engineer) to understand the entire project context. Update this file whenever significant architectural decisions or conventions change._
