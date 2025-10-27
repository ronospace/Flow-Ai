# MSc Data Science Thesis Proposal
## Realistic and Achievable Version

**Student:** Geoffrey Rono  
**Matriculation No.:** 74199495  
**Program:** MSc Data Science (90 ECTS)  
**Supervisor:** Prof. Dr. Iftikhar Ahmed  
**University:** University of Europe for Applied Sciences  
**Date:** October 27, 2025

---

## Title

**Predictive Modeling and Symptom Intelligence for Menstrual Health: A Machine Learning Approach Using Real-World App Data**

*Alternative:* **Ensemble Machine Learning for Personalized Menstrual Cycle Prediction: Development and Evaluation Using Flow Ai App Data**

---

## Problem Statement

### Healthcare Context
Menstrual health tracking is critical for **1.8 billion women** worldwide. However, existing period tracking applications predominantly use simple calendar-based predictions (averaging past cycles), achieving only **60-70% accuracy**. This limited accuracy:
- Reduces user trust and app engagement
- Fails to capture individual cycle variability and patterns
- Provides no personalized insights or symptom predictions
- Cannot identify irregular patterns requiring medical attention

### Technical Challenge
Current approaches face several limitations:
1. **Prediction Accuracy:** Simple averaging fails to model complex, non-linear cycle patterns
2. **Personalization:** One-size-fits-all models don't adapt to individual users
3. **Feature Utilization:** Most apps use only past cycle dates, ignoring symptoms, mood, and lifestyle factors
4. **Privacy Concerns:** Cloud-based ML raises GDPR/HIPAA compliance questions

### Research Opportunity
**Flow Ai** is a production-ready period tracking application currently in use by real testers across multiple countries (Kenya, Algeria, and growing). This presents a unique opportunity to:
- Apply machine learning to real-world menstrual health data
- Compare multiple ML algorithms for cycle prediction
- Evaluate the impact of feature engineering (symptoms, lifestyle factors)
- Validate predictions against actual user-reported cycle data
- Assess user satisfaction and trust in ML-powered predictions

**Research Gap:** While ensemble ML has been explored in healthcare, limited research exists on personalized menstrual cycle prediction using real app data with comprehensive feature sets (symptoms, mood, biometric indicators).

---

## Research Questions

### Primary Research Questions

**RQ1: Prediction Accuracy**  
*How do different machine learning algorithms (Linear Regression, Random Forest, Neural Networks, LSTM, Ensemble) compare in predicting menstrual cycle start dates?*

- **Hypothesis:** Ensemble methods will achieve 10-15% higher accuracy than simple calendar averaging
- **Metric:** Mean Absolute Error (MAE) in days, Accuracy within ±1 day

**RQ2: Feature Engineering Impact**  
*Which features (cycle characteristics, symptoms, mood, lifestyle factors) contribute most significantly to prediction accuracy?*

- **Hypothesis:** Incorporating symptom and mood data improves predictions by ≥10% compared to cycle dates alone
- **Method:** Feature importance analysis, ablation studies

**RQ3: Personalization vs. Generalization**  
*Do personalized models (trained per-user) outperform generalized models (trained across all users)?*

- **Hypothesis:** Personalized models achieve higher accuracy for users with ≥3 cycles of data
- **Analysis:** Per-user vs. global model performance comparison

**RQ4: User Trust and Acceptance**  
*How do users perceive ML-powered predictions in terms of trust, usefulness, and satisfaction?*

- **Method:** Qualitative analysis through surveys and user feedback
- **Metrics:** Likert scale ratings (1-5), Net Promoter Score (NPS)

### Secondary Research Questions

**RQ5: Data Sufficiency**  
*What is the minimum number of past cycles required for reliable ML predictions?*

**RQ6: Explainability**  
*Can we provide users with understandable explanations for cycle predictions (e.g., "based on your past 3 cycles and recent stress levels")?*

---

## Methodology

### Research Design
**Mixed-methods approach** combining:
1. **Quantitative:** ML model development and evaluation using real app data
2. **Qualitative:** User experience validation through surveys and feedback

### Phase 1: Data Collection & Preparation (Weeks 1-4)

#### 1.1 Current Data Status
**Source:** Flow Ai mobile application (iOS, Android)  
**Current Users:** 10-30 active testers across Kenya, Algeria, and expanding  
**Data Collection Period:** October 2025 - January 2026 (3-4 months)

#### 1.2 Expected Dataset

| Data Type | Expected Volume |
|-----------|----------------|
| **Users** | 10-30 active testers |
| **Cycles Recorded** | 1-3 cycles per user = 30-90 total cycles |
| **Daily Log Entries** | 200-600 daily records (symptoms, mood, etc.) |
| **Predictions Generated** | 50-150 predictions with ground truth |

**Database Structure (Firebase Firestore):**

**Collection: cycles**
```json
{
  "userId": "hashed_user_id",
  "cycleId": "cycle_uuid",
  "startDate": "2025-10-15",
  "endDate": "2025-10-20",
  "cycleLength": 28,
  "flowDuration": 5,
  "flowHeaviness": 3
}
```

**Collection: daily_logs**
```json
{
  "userId": "hashed_user_id",
  "date": "2025-10-16",
  "symptoms": ["cramping", "headache"],
  "moodScore": 3,
  "energyLevel": 2,
  "painLevel": 6,
  "notes": "text"
}
```

**Collection: predictions**
```json
{
  "userId": "hashed_user_id",
  "predictionId": "uuid",
  "modelType": "ensemble",
  "predictedDate": "2025-11-12",
  "confidence": 0.85,
  "actualDate": "2025-11-14",
  "error": 2
}
```

#### 1.3 Data Preprocessing
1. **Export from Firebase:** Anonymized JSON exports
2. **Data Cleaning:**
   - Remove incomplete cycles (missing start/end dates)
   - Handle missing symptom data (imputation or exclusion)
   - Outlier detection (cycle length <20 or >45 days)
3. **Feature Engineering:** Extract 20-30 key features (see below)
4. **Train/Test Split:** 70/30 temporal split (older cycles for training)

#### 1.4 Feature Engineering (Realistic Scope)

**Feature Categories (~25 features):**

| Category | Count | Examples |
|----------|-------|----------|
| **Cycle History** | 8 | Previous 3 cycle lengths, mean, std, trend |
| **Temporal** | 4 | Days since last period, day of week, season |
| **Symptoms** | 6 | Cramping severity, headache, bloating (binary/scale) |
| **Mood & Energy** | 4 | Mood score (1-5), energy level (1-5), stress indicator |
| **Lifestyle** | 3 | Sleep quality (if logged), activity level, notes sentiment |

*Note: Actual features depend on what users consistently log*

#### 1.5 Supplementary Synthetic Data (If Needed)

If real data is insufficient for robust model training (<50 cycles):
- Generate 50-100 synthetic cycles using statistical distributions from real data
- Maintain realistic variability (cycle length 21-35 days, 70% regularity)
- **Clearly mark and separate** synthetic data from real data in analysis
- Use only for initial model training, validate exclusively on real data

### Phase 2: Model Development & Evaluation (Weeks 5-10)

#### 2.1 Baseline Model
**Simple Calendar Average:**
- Prediction = Mean of past 3 cycle lengths
- Benchmark to beat

#### 2.2 Machine Learning Models

Implement and compare **5 algorithms:**

1. **Linear Regression**
   - Simple, interpretable baseline ML model
   - Features: Past cycle lengths, days since last period

2. **Random Forest**
   - Handles non-linear relationships
   - Provides feature importance scores
   - Hyperparameters: 50-100 trees, max_depth 10-15

3. **Neural Network (Feedforward)**
   - Architecture: Input(25) → Hidden(64) → Hidden(32) → Output(1)
   - Activation: ReLU, optimizer: Adam
   - Purpose: Capture complex patterns

4. **LSTM (Recurrent Neural Network)**
   - Sequence length: 3-6 past cycles
   - Hidden units: 32-64
   - Purpose: Temporal pattern learning

5. **Ensemble Model**
   - Weighted average of Random Forest (40%), Neural Network (40%), LSTM (20%)
   - Weights optimized via validation set performance

#### 2.3 Evaluation Metrics

**Quantitative:**
- **Mean Absolute Error (MAE):** Average days off from actual
- **Accuracy within ±1 day:** % predictions within 1 day of actual
- **Accuracy within ±2 days:** % predictions within 2 days
- **Root Mean Squared Error (RMSE):** Penalizes large errors
- **Per-User Accuracy:** Track performance for individual users

**Validation Strategy:**
- Temporal split: Train on cycles 1-N, test on cycle N+1
- Cross-validation: Leave-one-user-out (if ≥15 users)
- Statistical significance: Paired t-tests between models

#### 2.4 Feature Importance Analysis
- Random Forest: Built-in feature importance
- SHAP values: Explain individual predictions
- Ablation study: Remove feature categories and measure impact

### Phase 3: User Experience Evaluation (Weeks 11-13)

#### 3.1 User Survey (Qualitative)
**Target:** All Flow Ai active testers (~10-30 users)

**Survey Questions (Likert scale 1-5 + open-ended):**
1. "The period predictions are accurate for my cycle" (1-5)
2. "I trust the AI predictions" (1-5)
3. "The app helps me understand my cycle better" (1-5)
4. "I would recommend this app to friends" (NPS: 0-10)
5. "What would make the predictions more useful?" (open-ended)

**Analysis:**
- Descriptive statistics (mean, std)
- Correlation between accuracy and trust
- Thematic analysis of open-ended responses

#### 3.2 Prediction Confidence Analysis
- Do higher confidence predictions correlate with higher accuracy?
- User perception: Do users trust high-confidence predictions more?

### Phase 4: Analysis & Documentation (Weeks 14-16)

#### 4.1 Statistical Analysis
- ANOVA: Compare model performance across all algorithms
- Paired t-tests: Pairwise comparisons (e.g., Ensemble vs. Baseline)
- Effect size calculations (Cohen's d)
- Confidence intervals for all metrics

#### 4.2 Thesis Writing
- Introduction & Literature Review
- Methodology (detailed reproducible steps)
- Results (tables, figures, statistical tests)
- Discussion (interpretation, limitations, future work)
- Conclusion

**Target:** 70,000 characters (40-50 pages)

---

## Dataset (Realistic Scope)

### Primary Dataset: Flow Ai User Data

#### Data Source
- **Platform:** Flow Ai mobile app (iOS, Android)
- **Backend:** Firebase Firestore
- **Collection Period:** October 2025 - January 2026 (3-4 months)
- **Geographic Coverage:** Kenya, Algeria, expanding to other regions

#### Expected Dataset Size

| Metric | Realistic Estimate |
|--------|-------------------|
| **Active Users** | 10-30 testers |
| **Cycles per User** | 1-3 cycles recorded |
| **Total Cycles** | 30-90 cycles |
| **Daily Logs** | 200-600 entries |
| **Predictions** | 50-150 with ground truth |

**Data Sufficiency:**
- ✅ Sufficient for: Basic ML model training, algorithm comparison, correlation analysis
- ✅ Academic validity: Real-world data from production app, not synthetic or scraped
- ⚠️ Limitations: Small sample size limits generalizability, may need synthetic augmentation

#### Data Structure

**Table 1: Cycles**
| Field | Type | Example |
|-------|------|---------|
| user_id | String (hashed) | "user_a7f3" |
| cycle_id | String | "cycle_001" |
| start_date | Date | 2025-10-15 |
| end_date | Date | 2025-10-20 |
| cycle_length | Integer | 28 days |
| flow_duration | Integer | 5 days |
| flow_heaviness | Integer (1-5) | 3 |

**Table 2: Daily Logs**
| Field | Type | Example |
|-------|------|---------|
| user_id | String | "user_a7f3" |
| date | Date | 2025-10-16 |
| symptoms | Array | ["cramping", "headache"] |
| mood_score | Integer (1-5) | 3 |
| energy_level | Integer (1-5) | 2 |
| pain_level | Integer (0-10) | 6 |

**Table 3: Predictions**
| Field | Type | Example |
|-------|------|---------|
| prediction_id | String | "pred_001" |
| user_id | String | "user_a7f3" |
| model_type | String | "ensemble" |
| predicted_date | Date | 2025-11-12 |
| confidence | Float (0-1) | 0.85 |
| actual_date | Date | 2025-11-14 |
| error_days | Integer | 2 |

#### Data Quality Measures
- **Completeness:** Track % of days with logged data per user
- **Consistency:** Validate date ranges, cycle lengths within normal bounds
- **Accuracy:** Ground truth is user-reported actual cycle start (no external validation)

#### Privacy & Ethics

**Anonymization:**
- All user IDs hashed (SHA-256)
- No personal identifiers (names, emails, phone numbers)
- Location data aggregated to country-level only
- Age/demographics optional and aggregated

**User Consent:**
- In-app consent form for research participation
- "Your anonymized data may be used for academic research to improve predictions"
- Right to opt-out at any time
- Data deletion upon request

**Compliance:**
- GDPR-compliant (explicit consent, right to erasure)
- CCPA-compliant (transparency, opt-out)
- IRB/Ethics approval: Apply through University of Europe ethics committee

**Data Storage:**
- Firebase Firestore (encrypted at rest, TLS in transit)
- Research export: AES-256 encrypted local files
- Access: Researcher only, password-protected
- Retention: 2 years post-thesis, then deletion

### Secondary Dataset (Optional, for Validation)

If access is granted:
- **Natural Cycles** published datasets (if available through research agreement)
- **Apple Women's Health Study** aggregate data (for trend comparison)
- **Purpose:** Validate that Flow Ai findings align with larger population trends

---

## Expected Outcomes

### Academic Contributions
1. **Algorithm Comparison:** Empirical evaluation of 5 ML approaches for menstrual cycle prediction
2. **Feature Importance:** Identification of most predictive features for cycle forecasting
3. **Personalization Analysis:** Evidence for or against per-user model training
4. **User Acceptance Study:** Qualitative insights on trust in ML health predictions

### Practical Contributions
1. **Flow Ai Improvements:** Integrate best-performing model into production app
2. **Open Research:** Publish anonymized dataset (if ethically approved) for future research
3. **Recommendations:** Guidelines for FemTech apps on ML implementation

### Realistic Success Criteria
- **Model Performance:** Achieve ≥75% accuracy within ±2 days (vs. 65% baseline)
- **User Satisfaction:** ≥70% of users rate predictions as "useful" (4+ on Likert scale)
- **Academic Rigor:** Statistically significant results with proper validation

---

## Timeline (16 Weeks Total)

| Phase | Weeks | Key Activities | Deliverable |
|-------|-------|----------------|-------------|
| **Data Collection** | 1-4 | Export Firebase data, clean, preprocess | Clean dataset (30-90 cycles) |
| **Feature Engineering** | 3-5 | Extract features, exploratory analysis | Feature set (25 dimensions) |
| **Model Development** | 5-8 | Implement 5 algorithms, hyperparameter tuning | Trained models |
| **Model Evaluation** | 8-10 | Test on validation set, statistical tests | Performance metrics |
| **User Study** | 11-13 | Survey testers, analyze feedback | User satisfaction report |
| **Analysis & Writing** | 14-16 | Statistical analysis, draft thesis | Draft chapters |
| **Revision & Defense** | 17-18 | Incorporate feedback, prepare presentation | Final thesis |

**Total Duration:** 18 weeks (4.5 months) with 2-week buffer

---

## Strengths of This Realistic Approach

### ✅ **Honesty & Feasibility**
- Realistic dataset size (10-30 users, not 500-1,000)
- Achievable timeline (18 weeks, not 20 weeks with aggressive targets)
- Honest about limitations (small sample, may need synthetic augmentation)

### ✅ **Unique Value Proposition**
- Real production app with actual users
- International testers (Kenya, Algeria) adds diversity
- Live data collection during thesis period

### ✅ **Academic Rigor**
- Clear research questions with testable hypotheses
- Mixed methods (quantitative + qualitative)
- Proper statistical validation
- Ethical compliance (consent, anonymization, IRB)

### ✅ **Practical Impact**
- Findings directly improve Flow Ai app
- User feedback loop (testers benefit from improved predictions)
- Contribution to underserved FemTech research area

---

## Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Low user retention** | Medium | High | Engage testers regularly, incentivize logging, onboard new users continuously |
| **Insufficient data** | Medium | Medium | Use synthetic augmentation (clearly marked), focus on algorithm comparison rather than absolute accuracy |
| **Model underperformance** | Low | Medium | Still valuable to report negative results, analyze why, recommend improvements |
| **IRB delays** | Medium | Low | Apply early (Week 1), proceed with data collection in parallel (consent already in app) |
| **Technical challenges** | Low | Low | Models already implemented in app, just need evaluation framework |

---

## Why This Thesis Will Succeed

### ✅ **You Already Have:**
- Working production app (Flow Ai)
- Real users actively testing
- Firebase backend collecting data
- ML models implemented (ensemble system)
- International reach (Kenya, Algeria, growing)
- Supervisor support (Prof. Ahmed)

### ✅ **Realistic Expectations:**
- Small but real dataset > large synthetic dataset
- Academic focus on methodology and comparison, not production perfection
- Mixed methods provide multiple validation angles
- Honest about limitations shows maturity

### ✅ **Compelling Story:**
- Women's health is critically underserved in tech
- FemTech is a growing field
- Privacy-first approach (on-device ML)
- Real-world impact (users benefit during study)

---

**Signature:**  
Geoffrey Rono  
Email: geoffrey.rono@ue-germany.de  
Date: October 27, 2025

---

**Recommended for Prof. Ahmed Review:** This realistic version aligns expectations with actual capabilities while maintaining academic rigor.
