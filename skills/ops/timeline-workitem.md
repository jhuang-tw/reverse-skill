# Timeline + WorkItem / Coverage

> 可回放作战记录（Z3r0 timeline 思想）+ 覆盖勾选（WorkItem 思想）。  
> 全部落在 **`work/<case>/`**（仓库 gitignore），不进 skill 包正文。

## 目录约定

```text
work/<case>/
  scope.md           # 契约（ops/scope-contract.md）
  timeline.md        # 追加写，禁止改历史条目
  workitems.md       # 工作项与覆盖
  evidence/          # promoted Evidence records + referenced case-local artifacts
  notes/             # raw notes / transient analysis context
  report/            # formal/staged reports when the delivery profile needs them
```

初始化：

```powershell
powershell -File skills\scripts\case-init.ps1 -Hint "full pentest" -CaseName "acme-2026"
```

## timeline.md 格式

每条记录 **只追加**：

```markdown
## {ISO-8601} | {role} | {phase}
- action:
- command_or_ref:
- result_summary:
- artifacts: []      # relative paths under this case
- evidence_ids: []   # E-xxx only when an observation was promoted
- next:
```

**MUST NOT** 删除或改写已有 `##` 时间块（更正用新条目 + `corrects: {timestamp}`）。

## workitems.md 模板

```markdown
# Work Items

| ID | title | role | targets | surface | status | evidence | notes |
|----|-------|------|---------|---------|--------|----------|-------|
| WI-001 | Port scan edge | cie | {ip} | network | done | E-001 | |
| WI-002 | Auth bypass check | cpe | /api/login | web | blocked | | need creds |

status: pending | in_progress | blocked | done | cancelled

## Coverage
- [ ] Requested in_scope coverage is complete or residual scope is explicit
- [ ] Critical/High candidates triaged when applicable
- [ ] Validated findings have Evidence
- [ ] Material Path documented when the task has an attack/call/solve path
- [ ] Timeline has no unexplained major-phase gap for case/formal work
- [ ] Formal report exported via docs-generator — only when delivery profile is `formal` or the user requested it
- [ ] field-journal written — only when reusable new knowledge qualifies under convergence-delivery.md
```

Coverage checkboxes are profile-aware. An `inline` task does not need a case timeline/workitems package; a `case` task does not fail merely because no formal report or journal mutation was needed.

## attack-chain / pentest 挂钩

| Skill | MUST |
|-------|------|
| `attack-chain/` | 多阶段 case/formal 任务创建 case 目录；每阶段结束更新 workitems + timeline |
| `pentest-tools/` | 每次工具跑批后至少 1 条 timeline；原始批次输出保留为 artifact，只有 decision-relevant observation 才 promotion 成 Evidence |
| 其它 RE skill | case/formal profile 建议 timeline；正式出报告前补齐需要进入 handoff 的 Evidence 链 |

Raw→Evidence promotion 与 delivery profile 见 `convergence-delivery.md`。

## 特色

- Agent 友好的纯文本，diff/review 友好  
- 与 tool-index 命令路径可交叉引用  
- 不依赖 WebSocket 直播；需要时把 timeline 贴进报告即可  
