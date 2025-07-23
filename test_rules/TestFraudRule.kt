package test.rules

import some.FraudContext
import some.Rule
import some.RuleSignals
import some.RuleEvaluationResult

object TestFraudRule : Rule<TestFraudRule.Signals> {
    override val name: String = "Test Fraud Rule"
    override val jiraUrl: String = "https://example.com/TEST-123"
    override val description: String = "A test rule for feature gate creation"
    
    class Signals(override val signalContext: FraudContext) : RuleSignals

    override suspend fun evaluate(signals: Signals): RuleEvaluationResult {
        return RuleEvaluationResult.Pass("Test Rule Approved")
    }
}
