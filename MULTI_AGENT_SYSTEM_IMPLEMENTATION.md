# Building Multi-Agent Systems: Technical Implementation Guide

## How ClaudeKit's 15-Agent Architecture Actually Works

This document explains the **technical implementation** of building a multi-agent system like ClaudeKit, including architecture patterns, code examples, and best practices.

---

## Table of Contents

1. [Core Architecture Patterns](#core-architecture-patterns)
2. [Agent Coordination Mechanisms](#agent-coordination-mechanisms)
3. [Three Workflow Patterns](#three-workflow-patterns)
4. [Implementation Approaches](#implementation-approaches)
5. [Code Examples](#code-examples)
6. [State Management & Context Sharing](#state-management--context-sharing)
7. [Real-World Implementation with Claude Code](#real-world-implementation-with-claude-code)
8. [Best Practices & Gotchas](#best-practices--gotchas)

---

## Core Architecture Patterns

### 1. Agent Types in ClaudeKit

Each agent is actually a **specialized instruction set** (Markdown file) that tells Claude how to behave:

```
.claude/
├── agents/
│   ├── planner.md           # Agent instruction file
│   ├── researcher.md        # Agent instruction file
│   ├── ui-ux-designer.md    # Agent instruction file
│   └── [... 12 more]
```

**What's in an agent file?**

```markdown
# planner Agent

## Role
You are a planning and research coordination agent. Your job is to analyze
requirements and create detailed implementation plans before any code is written.

## When to Activate
- User requests a new feature
- User says "plan this" or "create a plan"
- User asks "how should we implement X?"

## Capabilities
- Break complex features into concrete tasks
- Research best practices and documentation
- Create TODO lists with dependencies
- Identify potential blockers
- Suggest testing strategies

## Process
1. **Understand Requirements**: Ask clarifying questions if needed
2. **Research Phase**: Use researcher agent to explore approaches
3. **Create Plan**: Break into tasks with TODO tracking
4. **Identify Dependencies**: Note what blocks what
5. **Suggest Testing**: Outline test strategy

## Expected Output Format
```
# Implementation Plan: [Feature Name]

## Research Phase
- [ ] Research item 1
- [ ] Research item 2

## Implementation Tasks
1. [ ] Task 1 (depends on: none)
2. [ ] Task 2 (depends on: Task 1)

## Testing Strategy
- Unit tests: ...
- Integration tests: ...

## Estimated Time: X hours
```

## Delegation
When you need:
- **Parallel research**: Delegate to researcher agent (query fan-out)
- **Database design**: Delegate to database-admin agent
- **Testing details**: Delegate to tester agent

## Restrictions
- DO NOT write code (that's for implementation phase)
- DO NOT skip planning (even if feature seems simple)
- DO NOT make assumptions (research or ask)
```

---

## Agent Coordination Mechanisms

### Mechanism 1: **Slash Commands** (Primary Interface)

Users trigger agents via commands:

```
.claude/
├── commands/
│   ├── plan.md              # Activates planner agent
│   ├── research.md          # Activates researcher agent
│   ├── cook.md              # Activates full workflow
│   └── [... 32 more]
```

**Example: `/plan` command**

```markdown
# /plan - Create Implementation Plan

When user types `/plan [feature description]`:

1. Activate the **planner** agent
2. Provide context from CLAUDE.md
3. Execute planning workflow:
   - Analyze requirements
   - Spawn researcher agents if needed
   - Create detailed plan
   - Output TODO list

## Example Usage
```
User: /plan add Stripe subscription billing
Agent: [Activates planner, researches Stripe docs, creates plan]
```
```

---

### Mechanism 2: **Agent-to-Agent Delegation**

Agents can invoke other agents programmatically:

```
planner agent decides it needs research
  ↓
  Invokes researcher agent with specific query
  ↓
  researcher spawns 3 parallel sub-researchers
  ↓
  Sub-researchers return findings
  ↓
  researcher synthesizes results
  ↓
  planner receives research, continues planning
```

**How this works technically:**

```typescript
// Pseudo-code for agent delegation

class PlannerAgent {
  async createPlan(feature: string) {
    // 1. Determine if research is needed
    const needsResearch = this.analyzeComplexity(feature);

    if (needsResearch) {
      // 2. Delegate to researcher agent
      const researchResults = await AgentOrchestrator.invoke({
        agent: 'researcher',
        query: `Best practices for ${feature}`,
        parallelism: 3  // Spawn 3 parallel researchers
      });

      // 3. Use research results in plan
      const plan = this.buildPlan(feature, researchResults);
      return plan;
    }

    // Simple feature, no research needed
    return this.buildPlan(feature);
  }
}
```

---

### Mechanism 3: **Context Sharing via CLAUDE.md**

All agents read the same context file:

```markdown
# CLAUDE.md (Shared Context)

## Project: ClaudeKit Landing Page

### Tech Stack
- Next.js 14 App Router
- TypeScript
- Tailwind CSS
- Stripe

### Code Standards
- Server Components by default
- Named exports (not default)
- Strict TypeScript

### File Boundaries
- NEVER modify .env.local
- ALWAYS update .env.example when adding env vars
```

**Every agent has this context** before they start working.

---

## Three Workflow Patterns

### Pattern 1: Sequential Chain Workflow

```
User: /cook add authentication feature

Orchestrator executes sequence:
1. planner agent      → Creates implementation plan
2. researcher agent   → Researches auth libraries (if needed)
3. database-admin     → Designs user/session schema
4. [implementation]   → Write the code
5. tester agent       → Generates test suite
6. code-reviewer      → Reviews for bugs/security
7. git-manager        → Creates commit and PR
```

**Implementation:**

```typescript
async function sequentialWorkflow(feature: string) {
  // Each step waits for previous to complete
  const plan = await runAgent('planner', { feature });

  const research = await runAgent('researcher', {
    queries: plan.researchItems
  });

  const schema = await runAgent('database-admin', {
    requirements: plan.databaseNeeds
  });

  // ... implementation happens ...

  const tests = await runAgent('tester', {
    code: implementedCode,
    coverage: 'comprehensive'
  });

  const review = await runAgent('code-reviewer', {
    code: implementedCode,
    tests: tests
  });

  if (review.approved) {
    await runAgent('git-manager', {
      action: 'commit-and-pr',
      changes: implementedCode
    });
  }
}
```

**When to use:** Features with dependencies (schema → code → tests → review)

---

### Pattern 2: Parallel Execution Workflow

```
User: /cook build dashboard with charts, user profile, and notifications

Orchestrator executes in parallel:
┌─ ui-ux-designer → Dashboard charts component
├─ ui-ux-designer → User profile component
└─ ui-ux-designer → Notifications component

All three complete independently, then integrate
```

**Implementation:**

```typescript
async function parallelWorkflow(tasks: Task[]) {
  // Launch all agents simultaneously
  const results = await Promise.all([
    runAgent('ui-ux-designer', { component: 'DashboardCharts' }),
    runAgent('ui-ux-designer', { component: 'UserProfile' }),
    runAgent('ui-ux-designer', { component: 'Notifications' })
  ]);

  // Integrate results
  return integrateComponents(results);
}
```

**When to use:** Independent tasks with no dependencies

**Speed improvement:** 3 tasks in parallel = 3x faster

---

### Pattern 3: Query Fan-Out Workflow (Most Powerful!)

```
User: What's the best authentication library for Next.js?

researcher agent (coordinator):
  ├─ Spawn sub-researcher #1: Official documentation
  ├─ Spawn sub-researcher #2: Community best practices
  └─ Spawn sub-researcher #3: Performance benchmarks

All 3 research in parallel (fan-out)
  ↓
Results return to coordinator (fan-in)
  ↓
Coordinator synthesizes findings
  ↓
Returns comprehensive recommendation
```

**Implementation:**

```typescript
async function queryFanOutWorkflow(question: string) {
  // Define research angles
  const researchAngles = [
    {
      angle: 'official-docs',
      prompt: `Research official documentation for: ${question}`
    },
    {
      angle: 'community',
      prompt: `Research community best practices for: ${question}`
    },
    {
      angle: 'performance',
      prompt: `Research performance and gotchas for: ${question}`
    }
  ];

  // Fan-out: Launch 3 parallel researchers
  const findings = await Promise.all(
    researchAngles.map(angle =>
      runAgent('researcher', {
        focus: angle.angle,
        prompt: angle.prompt,
        depth: 'thorough'
      })
    )
  );

  // Fan-in: Synthesize results
  const synthesis = await runAgent('researcher', {
    action: 'synthesize',
    findings: findings,
    outputFormat: 'recommendation'
  });

  return synthesis;
}
```

**When to use:**
- Complex decisions requiring multiple perspectives
- Research with multiple dimensions (official vs community vs performance)
- Comprehensive analysis before architectural choices

**Benefits:**
- 3x faster than sequential research
- More comprehensive (covers blind spots)
- Reduces bias (multiple perspectives)

---

## Implementation Approaches

### Approach 1: **Claude Code + Markdown Instructions** (ClaudeKit's Approach)

**Architecture:**
```
.claude/
├── agents/                  # Markdown files with agent instructions
│   ├── planner.md          # "You are a planning agent..."
│   ├── researcher.md       # "You are a research agent..."
│   └── [... 13 more]
├── commands/               # Slash commands that activate agents
│   ├── plan.md            # Invokes planner agent
│   ├── cook.md            # Invokes full workflow
│   └── [... 33 more]
└── CLAUDE.md              # Shared context all agents read
```

**How it works:**
1. User types `/plan add authentication`
2. Claude Code reads `.claude/commands/plan.md`
3. That command says "Activate planner agent"
4. Claude Code reads `.claude/agents/planner.md`
5. Claude Code reads `CLAUDE.md` for project context
6. Claude follows planner agent instructions
7. Planner may delegate to researcher agent
8. Process repeats recursively

**Pros:**
- ✅ No code needed (just Markdown instructions)
- ✅ Easy to modify agents (edit Markdown)
- ✅ Works natively with Claude Code
- ✅ Version controllable (git diff on .md files)

**Cons:**
- ❌ Limited to what Claude Code supports
- ❌ No programmatic control flow
- ❌ Hard to enforce strict workflows

---

### Approach 2: **Programmatic Orchestration** (For Custom Systems)

**Architecture:**
```typescript
// Agent orchestrator with programmatic control

class AgentOrchestrator {
  agents: Map<string, Agent>;

  async runWorkflow(workflow: Workflow) {
    switch (workflow.type) {
      case 'sequential':
        return this.runSequential(workflow.steps);
      case 'parallel':
        return this.runParallel(workflow.tasks);
      case 'fan-out':
        return this.runFanOut(workflow.query);
    }
  }

  async runSequential(steps: Step[]) {
    const results = [];
    for (const step of steps) {
      const result = await this.invokeAgent(step.agent, step.input);
      results.push(result);
    }
    return results;
  }

  async runParallel(tasks: Task[]) {
    return Promise.all(
      tasks.map(task => this.invokeAgent(task.agent, task.input))
    );
  }

  async runFanOut(query: Query) {
    // Spawn multiple researchers
    const angles = this.determineResearchAngles(query);
    const findings = await Promise.all(
      angles.map(angle => this.invokeAgent('researcher', angle))
    );

    // Synthesize
    return this.invokeAgent('synthesizer', { findings });
  }

  async invokeAgent(agentName: string, input: any) {
    const agent = this.agents.get(agentName);
    const context = await this.loadContext();  // CLAUDE.md

    return agent.run({
      input,
      context,
      canDelegate: (targetAgent) => this.invokeAgent(targetAgent, input)
    });
  }
}
```

**Pros:**
- ✅ Full control over workflow logic
- ✅ Can enforce strict patterns
- ✅ Error handling and retries
- ✅ Metrics and observability

**Cons:**
- ❌ More complex to implement
- ❌ Requires programming
- ❌ Harder to modify workflows

---

### Approach 3: **Hybrid** (Best of Both Worlds)

```
Programmatic orchestration for control flow
+
Markdown instructions for agent behavior

Example:
- Orchestrator enforces sequential workflow
- But each agent reads Markdown for its instructions
```

---

## Code Examples

### Example 1: Implementing the `planner` Agent

**File: `.claude/agents/planner.md`**

```markdown
# planner Agent - Planning & Research Coordination

## Identity
You are a senior technical planning agent. You create detailed implementation
plans before any code is written. You think like a tech lead.

## Activation Triggers
- User types `/plan [feature]`
- User asks "how should we implement X?"
- Another agent delegates planning to you

## Your Process

### Step 1: Understand Requirements
Ask clarifying questions:
- What is the core functionality?
- Who are the users?
- What are the constraints?
- Are there dependencies on existing features?

### Step 2: Research (Delegate to researcher agent)
For complex features, invoke researcher agent:
```
/research best practices for [feature]
```

### Step 3: Create Implementation Plan
Structure:
```
# Implementation Plan: [Feature Name]

## Overview
[1-2 sentence description]

## Research Findings
[Summary from researcher agent]

## Tasks
1. [ ] Task 1 (Estimated: 2h)
2. [ ] Task 2 (Estimated: 1h, Depends on: Task 1)
...

## Testing Strategy
- Unit tests: [specific areas]
- Integration tests: [workflows to test]
- E2E tests: [user journeys]

## Risks & Mitigations
- Risk 1: [mitigation strategy]
- Risk 2: [mitigation strategy]

## Total Estimated Time: Xh
```

### Step 4: Get User Approval
Present plan and ask: "Does this plan look good? Any changes needed?"

## Restrictions
- ❌ DO NOT write code (planning phase only)
- ❌ DO NOT skip research for complex features
- ❌ DO NOT make assumptions without clarifying

## Delegation Patterns
- **Need research?** → Invoke `researcher` agent
- **Need database design?** → Invoke `database-admin` agent
- **Need test details?** → Invoke `tester` agent

## Context
Always read CLAUDE.md for:
- Tech stack
- Code standards
- File boundaries
- Project conventions
```

---

### Example 2: Implementing Query Fan-Out in `researcher` Agent

**File: `.claude/agents/researcher.md`**

```markdown
# researcher Agent - Parallel Research & Best Practices

## Identity
You coordinate parallel research efforts using query fan-out technique.
You spawn multiple sub-researchers to investigate different angles simultaneously.

## Activation Triggers
- User types `/research [topic]`
- planner agent delegates research to you
- Any agent needs comprehensive research

## Query Fan-Out Process

### Step 1: Analyze Research Question
Identify research dimensions:
- Official documentation
- Community best practices
- Performance & benchmarks
- Security considerations
- Real-world usage patterns

### Step 2: Spawn 3 Parallel Sub-Researchers
Launch simultaneously:

**Sub-Researcher #1 (Official Sources):**
```
Focus: Official documentation, API references, framework recommendations
Sources: Docs, GitHub repos, official guides
Depth: Thorough
```

**Sub-Researcher #2 (Community & Real-World):**
```
Focus: Community discussions, real-world usage, developer experience
Sources: Stack Overflow, Reddit, GitHub issues, blog posts
Depth: Practical insights
```

**Sub-Researcher #3 (Performance & Gotchas):**
```
Focus: Performance benchmarks, common pitfalls, edge cases
Sources: Benchmarks, issue trackers, gotcha compilations
Depth: Critical analysis
```

### Step 3: Synthesize Findings
Compare all 3 research reports:
- What's consistent across sources?
- What are the trade-offs?
- What are the gotchas?
- What's the recommendation?

### Step 4: Output Format
```
# Research Report: [Topic]

## Summary
[2-3 sentence executive summary]

## Detailed Findings

### Official Documentation Says:
[Findings from sub-researcher #1]

### Community Experience Shows:
[Findings from sub-researcher #2]

### Performance & Gotchas:
[Findings from sub-researcher #3]

## Recommendation
Based on research, we recommend: [specific choice]

**Rationale:**
- Pro 1
- Pro 2
- Con 1 (acceptable because...)

## Implementation Notes
- [Key consideration 1]
- [Key consideration 2]
```

## Example Usage

**Input:** "What's the best auth library for Next.js 14?"

**Sub-Researcher #1 Findings:**
- NextAuth.js v5 (official recommendation)
- Clerk (first-party Next.js integration)
- Better Auth (newer, TypeScript-first)

**Sub-Researcher #2 Findings:**
- NextAuth.js: Most popular (23k stars) but v5 migration is breaking
- Clerk: Best DX, but expensive at scale
- Better Auth: Growing momentum, zero lock-in

**Sub-Researcher #3 Findings:**
- NextAuth.js: JWT = fast, DB = secure but slower
- Clerk: Edge-optimized, minimal latency
- Better Auth: Comparable to NextAuth with DB sessions

**Synthesized Recommendation:**
```
Recommendation: Better Auth

Rationale:
✓ TypeScript-first (matches your Next.js stack)
✓ Zero vendor lock-in (you own the database)
✓ Works with any React framework
✓ MIT licensed (no pricing concerns)
✓ Good performance (comparable to NextAuth)

Acceptable trade-off:
⚠️ Newer = smaller ecosystem (but growing fast)
⚠️ Manual database migrations (but you have full control)
```
```

---

### Example 3: Sequential Workflow Implementation

**File: `.claude/commands/cook.md`**

```markdown
# /cook - Full Feature Implementation Workflow

## What This Does
Executes complete feature implementation from planning to deployment:
1. Planning (planner agent)
2. Research (researcher agent, if needed)
3. Implementation (write code)
4. Testing (tester agent)
5. Review (code-reviewer agent)
6. Git operations (git-manager agent)

## Usage
```
/cook add Stripe subscription billing
/cook refactor authentication to use Better Auth
/cook fix bug in checkout flow
```

## Workflow Steps

### Step 1: Planning Phase
Invoke planner agent:
```
Activate: planner
Input: [feature description]
Output: Detailed implementation plan
```

### Step 2: Research Phase (Conditional)
If plan indicates research needed:
```
Activate: researcher
Input: [research questions from plan]
Output: Research findings
```

### Step 3: Implementation Phase
Follow plan and implement:
- Read CLAUDE.md for code standards
- Write code following conventions
- Create necessary files
- Update existing files

### Step 4: Testing Phase
Invoke tester agent:
```
Activate: tester
Input: [implemented code]
Output: Comprehensive test suite (unit + integration + E2E)
```

Run tests:
```bash
npm run test
npm run test:e2e
```

### Step 5: Code Review Phase
Invoke code-reviewer agent:
```
Activate: code-reviewer
Input: [implemented code + tests]
Output: Review report (bugs, security, best practices)
```

Address any issues found.

### Step 6: Git Operations Phase
Invoke git-manager agent:
```
Activate: git-manager
Input: [all changes]
Actions:
  - Create professional commit message
  - Stage changes
  - Commit
  - Create PR (if requested)
```

### Step 7: Completion
Report to user:
```
✅ Feature implemented: [name]
✅ Tests written: [count] tests, [coverage]%
✅ Code reviewed: [approval status]
✅ Committed: [commit hash]
✅ PR created: [PR URL] (if applicable)

Total time: [duration]
```

## Error Handling
- If tests fail → Invoke debugger agent
- If code review fails → Fix issues and re-review
- If implementation blocked → Report to user with specific blocker
```

---

## State Management & Context Sharing

### Challenge: How Do Agents Share Information?

**Problem:**
```
planner creates plan → researcher does research → How does implementation phase get both?
```

### Solution 1: **Shared Files** (ClaudeKit Approach)

```
.claude/
├── state/
│   ├── current-plan.md        # Latest plan from planner
│   ├── research-findings.md   # Latest research
│   └── progress.md            # Current progress
```

**How it works:**
1. planner agent writes to `current-plan.md`
2. researcher agent reads plan, writes to `research-findings.md`
3. Implementation phase reads both files
4. git-manager agent updates `progress.md`

**Implementation:**

```markdown
# In planner agent instructions:

After creating plan, write to `.claude/state/current-plan.md`:
```
[Your plan here]
```

Other agents can read this file to see the plan.
```

---

### Solution 2: **Context Accumulation**

```typescript
class AgentContext {
  plan?: Plan;
  research?: Research;
  implementation?: Code;
  tests?: Tests;
  review?: Review;

  // Each agent adds to context
  async runPlannerAgent() {
    this.plan = await planner.run();
  }

  async runResearcherAgent() {
    // Researcher has access to plan via this.plan
    this.research = await researcher.run({ plan: this.plan });
  }

  async runImplementation() {
    // Implementation has access to both plan and research
    this.implementation = await implement({
      plan: this.plan,
      research: this.research
    });
  }
}
```

---

### Solution 3: **Journal System** (Best for Long-Running Projects)

**File: `.claude/journal/2025-01-08.md`**

```markdown
# Development Journal: 2025-01-08

## Morning: Planning Authentication Feature

**planner agent:**
Created implementation plan for authentication using Better Auth.
See: `.claude/state/auth-plan.md`

Key decisions:
- Using Better Auth (not NextAuth)
- Database: PostgreSQL with Prisma
- OAuth providers: Google, GitHub

## Afternoon: Research Phase

**researcher agent:**
Completed parallel research on Better Auth integration.
See: `.claude/state/better-auth-research.md`

Findings:
- Official docs are comprehensive
- Community reports excellent DX
- No major gotchas found

## Evening: Implementation

**Implemented:**
- Database schema (users, sessions, accounts)
- Better Auth configuration
- OAuth provider setup
- Protected route middleware

**Tests written:** 15 unit tests, 5 integration tests

**Code review status:** Passed ✅

**Committed:** abc123def "Add Better Auth authentication system"
```

**Benefits:**
- ✅ Historical record of decisions
- ✅ Context for future work
- ✅ Helps new agents understand what happened
- ✅ Debugging aid (what changed when?)

---

## Real-World Implementation with Claude Code

### How ClaudeKit Actually Works (Reverse Engineered)

**1. User types `/plan add Stripe subscriptions`**

**2. Claude Code reads `.claude/commands/plan.md`:**
```markdown
# /plan Command

Activate the planner agent:
- Read `.claude/agents/planner.md` for instructions
- Read `CLAUDE.md` for project context
- Execute planning workflow
```

**3. Claude Code loads context:**
```markdown
Context loaded:
- planner agent instructions
- CLAUDE.md (tech stack, code standards, file boundaries)
- Recent journal entries (if any)
- Current repository state
```

**4. Claude follows planner agent instructions:**
```markdown
# From .claude/agents/planner.md:

You are a planning agent. When given a feature:
1. Analyze requirements
2. If complex, delegate to researcher: /research [topic]
3. Create detailed implementation plan
4. Write plan to `.claude/state/current-plan.md`
5. Present plan to user
```

**5. planner determines research is needed:**
```markdown
planner agent's decision:
"Stripe subscriptions are complex. Need to research best practices."

Action: Invoke researcher agent
```

**6. Claude Code activates researcher agent:**
```markdown
Context loaded:
- researcher agent instructions
- CLAUDE.md
- Current plan (from planner)

researcher agent spawns 3 parallel investigations:
1. Stripe official docs
2. Community integration patterns
3. Webhook handling best practices
```

**7. Research completes, synthesis happens:**
```markdown
researcher findings written to:
.claude/state/stripe-research.md

Key findings:
- Use Stripe SDK v14+
- Webhooks MUST verify signatures
- Use test mode for development
```

**8. planner incorporates research into final plan:**
```markdown
# Implementation Plan: Stripe Subscriptions

## Research Findings
[Summary from researcher agent]

## Tasks
1. [ ] Install Stripe SDK v14
2. [ ] Set up webhook endpoint with signature verification
3. [ ] Create subscription management API routes
...

Plan written to: .claude/state/current-plan.md
```

**9. User sees final plan and approves:**
```
User: Looks good, implement it
```

**10. Implementation phase begins:**
```markdown
Implementation agent:
- Reads plan from .claude/state/current-plan.md
- Reads research from .claude/state/stripe-research.md
- Reads CLAUDE.md for code standards
- Implements according to plan
```

**11. After implementation, tester agent runs:**
```markdown
tester agent:
- Reads implemented code
- Reads plan (knows what to test)
- Generates test suite
- Runs tests
```

**12. code-reviewer agent reviews:**
```markdown
code-reviewer agent:
- Analyzes code for bugs
- Checks security (webhook signature verification? ✅)
- Verifies best practices
- Approves or requests changes
```

**13. git-manager agent commits:**
```markdown
git-manager agent:
- Creates professional commit message
- Stages changes
- Commits
- Creates PR if requested
```

---

## Best Practices & Gotchas

### Best Practice 1: **Always Provide Context**

❌ **Bad:**
```markdown
# planner agent instruction

Create a plan for the feature.
```

✅ **Good:**
```markdown
# planner agent instruction

Before planning:
1. Read CLAUDE.md for tech stack and code standards
2. Read recent journal entries for context
3. Check `.claude/state/current-plan.md` for related work

Create plan with:
- Tech stack from CLAUDE.md
- Code standards from CLAUDE.md
- Awareness of existing work
```

---

### Best Practice 2: **Explicit Delegation Patterns**

❌ **Bad:**
```markdown
If you need help, ask another agent.
```

✅ **Good:**
```markdown
Delegation patterns:
- Need research? → `/research [topic]` (invokes researcher agent)
- Need database schema? → Invoke database-admin agent
- Need tests? → Invoke tester agent

When delegating, provide:
- Clear question or requirement
- Context from your current work
- Expected output format
```

---

### Best Practice 3: **State Persistence**

❌ **Bad:**
Keep everything in memory (lost between sessions)

✅ **Good:**
```markdown
After completing work, write to persistent storage:

Plans → .claude/state/current-plan.md
Research → .claude/state/[topic]-research.md
Progress → .claude/journal/[date].md
Decisions → .claude/decisions/[decision-name].md
```

---

### Gotcha 1: **Context Limits**

**Problem:**
```
You load:
- Agent instructions (2,000 tokens)
- CLAUDE.md (5,000 tokens)
- Journal entries (3,000 tokens)
- Current codebase (50,000 tokens)

Total: 60,000 tokens (approaching limit)
```

**Solution:**
- Summarize old journal entries
- Only load relevant parts of codebase
- Use embeddings/vector search for large codebases

---

### Gotcha 2: **Agent Loops**

**Problem:**
```
planner → researcher → planner → researcher → (infinite loop)
```

**Solution:**
```markdown
# In agent instructions:

Maximum delegation depth: 2
- You can delegate once
- That agent can delegate once
- No further delegation allowed

Track delegation depth in context
```

---

### Gotcha 3: **Inconsistent Agents**

**Problem:**
Same agent gives different results on different runs

**Solution:**
```markdown
# In agent instructions:

Always follow this exact process:
1. Step 1 (specific action)
2. Step 2 (specific action)
3. Step 3 (specific action)

Use templates for output:
[Exact template here]

Reference examples:
[Show 2-3 examples of good output]
```

---

## Summary

### Key Takeaways

1. **Multi-agent systems = Specialized instruction sets**
   - Each agent is a Markdown file with specific instructions
   - Agents share context via CLAUDE.md and state files

2. **Three coordination patterns:**
   - Sequential (dependencies)
   - Parallel (independent tasks)
   - Fan-out (comprehensive research)

3. **Implementation approaches:**
   - Markdown-based (ClaudeKit, easy to modify)
   - Programmatic (full control, more complex)
   - Hybrid (best of both)

4. **State management is critical:**
   - Shared files for cross-agent communication
   - Journal system for historical context
   - Explicit delegation patterns

5. **Best practices:**
   - Always provide context
   - Explicit delegation patterns
   - State persistence
   - Prevent infinite loops
   - Consistent agent behavior

---

## Next Steps

Want to build your own multi-agent system?

1. **Start simple:** One agent (planner) + one command (/plan)
2. **Add second agent:** researcher with fan-out pattern
3. **Build state system:** Shared files for context
4. **Add workflows:** Sequential → Parallel → Fan-out
5. **Scale up:** Add more specialized agents as needed

---

**Questions?**

Which aspect should I dive deeper into?
- Agent instruction patterns?
- Workflow orchestration code?
- State management strategies?
- Error handling in multi-agent systems?
- Real code examples for specific use cases?
