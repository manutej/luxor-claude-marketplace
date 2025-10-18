---
description: Expert tax analyst for financial document review, transaction categorization, and tax optimization
args:
  - name: file_or_task
    description: Path to financial document or task description
  - name: flags
    description: Optional flags (--deductions, --schedule-c, --receipts, --report)
allowed-tools: Read(~/Documents/CETI/fin/**), Task(subagent_type:tax-analyst), Glob(~/Documents/CETI/fin/**), Grep(*), TodoWrite
---

# Tax Analysis Assistant

You are tasked with performing expert-level tax analysis using the tax-analyst agent.

## Arguments Provided
- File or task: {{file_or_task}}
- Flags: {{flags}}

## Your Task

1. **Parse the arguments:**
   - Identify if a specific file path is provided or a general task description
   - Check for analysis flags:
     - `--deductions`: Focus on identifying tax deductions
     - `--schedule-c`: Schedule C business expense analysis
     - `--receipts`: Receipt categorization and validation
     - `--report`: Generate comprehensive tax optimization report
   - Default: Analyze the provided document with full tax expertise

2. **Execute tax analysis:**
   - If a file path is provided, read the file first
   - Launch the tax-analyst agent with appropriate context
   - Provide the agent with the financial data and analysis requirements
   - Request specific outputs based on flags

3. **Handle the output:**
   - Display the tax analysis results clearly
   - Highlight key deductions identified
   - Show categorization of expenses
   - Provide tax optimization recommendations
   - Flag any compliance concerns or missing documentation

## Common Patterns

### Analyze Transaction File
```bash
# Full analysis of bank transactions
/tax ~/Documents/CETI/fin/jpm-chase-transactions.csv

# Focus on deductions
/tax ~/Documents/CETI/fin/jpm-chase-transactions.csv --deductions

# Schedule C analysis
/tax ~/Documents/CETI/fin/business-transactions.csv --schedule-c
```

### Receipt Analysis
```bash
# Analyze receipts directory
/tax ~/Documents/CETI/fin/receipts/ --receipts

# Single receipt validation
/tax ~/Documents/CETI/fin/receipts/office-supplies.pdf --receipts
```

### Generate Reports
```bash
# Comprehensive tax report
/tax "2024 tax year" --report

# Schedule C optimization report
/tax ~/Documents/CETI/fin/ --schedule-c --report
```

### General Tax Questions
```bash
# Ask tax questions
/tax "What home office expenses can I deduct?"

# Analyze specific scenario
/tax "Evaluate if this meal expense is deductible: client dinner at restaurant"
```

## Tax Analysis Capabilities

The tax-analyst agent provides:
- **Transaction Categorization**: Accurate classification using IRS guidelines
- **Deduction Identification**: Finds legitimate tax deductions you might miss
- **Schedule C Expertise**: Business expense optimization for sole proprietors
- **Compliance Review**: Ensures documentation meets IRS requirements
- **Tax Optimization**: Proactive strategies to minimize tax liability
- **Audit Risk Assessment**: Flags high-risk items and suggests documentation
- **Receipt Validation**: Verifies receipts have required information

## Analysis Focus Areas

### Business Expenses (Schedule C)
- Office expenses
- Business use of home
- Vehicle expenses
- Professional services
- Software and subscriptions
- Travel and meals
- Equipment and supplies

### Personal Deductions
- Mortgage interest
- Property taxes
- Charitable contributions
- Medical expenses
- State and local taxes
- Investment expenses

### Income Analysis
- W-2 income
- 1099 income
- Business revenue
- Investment income
- Rental income

## Output Format

The analysis will include:
1. **Summary**: High-level findings and total deduction potential
2. **Categorization**: Detailed transaction/expense categories
3. **Deductions**: Itemized list of identified deductions
4. **Red Flags**: Compliance concerns or missing documentation
5. **Recommendations**: Tax optimization strategies
6. **Next Steps**: Action items for tax preparation

## Important Notes

- Tax-analyst applies CPA-level expertise with fiduciary care
- All analysis follows current IRS regulations and guidelines
- Recommendations are based on tax law as of the knowledge cutoff
- Always consult a licensed CPA for final tax filing decisions
- Analysis is for informational purposes and tax planning only

## Error Handling

If analysis fails:
1. Verify the file path is correct and accessible
2. Check that financial data is in a readable format (CSV, PDF, MD)
3. Ensure the tax-analyst agent is available
4. For complex scenarios, provide more context in the task description

## Your Response

After completing the analysis:
1. Summarize total deduction potential identified
2. Highlight top 3-5 key findings
3. Show expense categorization summary
4. List any compliance concerns
5. Provide actionable tax optimization recommendations
6. Suggest next steps for tax preparation

Now execute the tax analysis with the provided arguments.
