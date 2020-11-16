# 1. 패키지 설치하기와 로딩하기 ----
install.packages("readxl")
install.packages("writexl")
install.packages("tidyverse")
install.packages("e1071")
install.packages("GGally")
install.packages("psych")  # 싸이크(심리)
library(readxl)
library(writexl)
library(tidyverse)
library(e1071)
library(GGally)
library(psych)

# 2. 작업공간 설정하기 ----
setwd("d:/KCISA")
getwd


# 3. 데이터 읽어오기
culture <- readxl::read_excel(path      = "culture.xlsx",
                              sheet     = "DM",
                              col_names = TRUE)


culture %>%
  dplyr::mutate(TOTAL_VALUE = MOBILE_SCCNT_VALUE + PC_SCCNT_VALUE + SCCNT_SM_VALUE) -> culture


# 4. 상관분석 ----
# 상관 : 직선의 관계 = 선형의 관계
# 자료 : 2개의 자료(열 = 변수 = Feature = Label)
# 양적 자료 : 상관분석 하려면 자료가 다 양적 자료여야 함
# paired(쌍) 되어 있어야 함

# 4.1 산점도(Scatter plot) : x와 y간의 관계를 시각화 ----
# 직선의 관계를 시각화
culture %>% 
  ggplot2::ggplot(mapping = aes(x = MOBILE_SCCNT_VALUE,
                                y = PC_SCCNT_VALUE)) +  # y축에 더 중요한 것을 넣기
  ggplot2::geom_point()
  

# 4.2 산점행렬도(SPM : Scatter plot Matrix) ----
culture %>% 
  purrr::keep(is.numeric)  %>% 
  dplyr::select(-c(SN, SCCNT_DE)) %>% 
  GGally::ggpairs() 
  
  
# 4.3 상관계수 ----
# Coefficient of Correlation
# 직선의 관계를 수치화한 것 : 둘 간의 직선의 관계가 얼마인지 알고 싶어서
cor(culture$RANK,
    culture$MOBILE_SCCNT_VALUE,
    method = "pearson")       # pearson이 디폴트임

culture %>% 
  purrr::keep(is.numeric)  %>% 
  dplyr::select(-c(SN, SCCNT_DE)) %>% 
  cor(method   = "pearson") %>% 
  round(digits = 3)

# 상관계수 해석의 일반적인 가이드(항상 진리는 아님!)
# 0.0 <= |r| < 0.2  : 상관관계가 없다.
# 0.2 <= |r| < 0.4  : 약한 상관관계가 있다.
# 0.4 <= |r| < 0.6  : 보통의 상관관계가 있다.
# 0.6 <= |r| < 0.8  : 강한(높은) 상관관계가 있다.
# 0.8 <= |r| <= 1.0 : 매우 강한(높은) 상관관계가 있다.


# 4.4 상관분석 ----
# 가설검정 중의 하나
# 귀무가설 : 두 양적 자료 간에 상관관계가 없다.
# 대립가설 : 두 양적 자료 간에 상관관계가 있다.
cor.test(culture$RANK, 
         culture$MOBILE_SCCNT_VALUE, 
         method = "pearson")     
  
  
# p-value = 0.000 < 유의수준(alpha) = 0.05 : 결론은 대립가설
# 유의확률이 0.000이므로 유의수준 0.05에서
# 'RANK'와' 'MOBILE_SCCNT_VALUE' 간에는
# 통계적으로 유의한 음의 상관관계가 있는 것으로 나타났다. 
# (so, 일단 RANK는 중요하게 고려해야겠다는 아이디어를 얻을 수 있음)

culture %>% 
  purrr::keep(is.numeric) %>% 
  dplyr::select(-c(SN,SCCNT_DE)) %>% 
  psych::corr.test(method = "pearson")


# 5. 회귀분석(Regression Analysis) ----
# 인과관계를 분석함
# 예측(이 숫자가 미래에 어떤 값이 될 지를 정확히 예측하고 싶어서)을 주로 함. 물론 분류에도 사용됨.
# 보통은 선형 회귀분석을 많이 함(이유는? 해석이 쉽기 때문. 실제는 비선형으로 되어있음. 비선형으로 접근하면 정확도는 높아지지만 설명이 힘듦)

# 보통은 다중선형 회귀분석을 함
# 단순선형 회귀분석 : X가 1개, Y가 1개. 잘 안함
# 다중선형 회귀분석 : X가 2개 이상, y는 1개  
# x에는 양적 자료도 가고 질적 자료도 가긴함

# 기본은 X : 양적 자료, Y : 양적 자료
# 에 질적 자료도 갈 수 있지만 그냥 못 감.
# X가 질적 자료인 경우에는 더미 변수(dummy variable)로 변경해야 함


# 회귀분석결과 <- lm(formula = Y ~ X1 + X2 + ..., data = 분석할 데이터)
# 참고 : lm : linear model
# summary(회귀분석결과)   <- 회귀분석한 결과는 consol에 쭉 뿌려줌
culture_model <- lm(formula = SCCNT_SM_VALUE ~ RANK + MOBILE_SCCNT_VALUE + PC_SCCNT_VALUE,
                    data    = culture)
summary(culture_model)   # 그치만 수치가 통계적으로 나와서 힘듦

# 회귀분석 결과의 해석
# 1단계 : 회귀모형의 타당성
# 귀무가설 : 회귀모형은 타당하지 않다.
# 대립가설 : 회귀모형은 타당하다.        회귀 모형:(Y에다 뭘 두고 X에다 뭘 두다)

# F-statistic: 5.015e+31 on 3 and 4177 DF,  p-value: < 2.2e-16  (제일 마지막에 있는 이게 결과임)
# p-value = 0.000 < 유의수준 = 0.05 : 결론 대립가설

# 2단계 : X의 유의성 검정
# 귀무가설 : X는 Y에게 영향을 주지 않는다.
# 대립가설 : X는 Y에게 영향을 준다.

# Coefficients:
#                     Estimate Std. Error        t value     Pr(>|t|) <- 이게 p-value
# (Intercept)        -1.004e-12     8.164e-14   -1.230e+01   <2e-16
# RANK                2.644e-13     9.104e-15    2.905e+01   <2e-16
# MOBILE_SCCNT_VALUE  1.000e+00     1.123e-16    8.902e+15   <2e-16
# PC_SCCNT_VALUE      1.000e+00     3.654e-16    2.737e+15   <2e-16
# 
# RANK               : p-value = 0.000 < 유의수준 = 0.05 : 결론 대립가설 
# MOBILE_SCCNT_VALUE : p-value = 0.000 < 유의수준 = 0.05 : 결론 대립가설 
# PC_SCCNT_VALUE     : p-value = 0.000 < 유의수준 = 0.05 : 결론 대립가설 

# / 즉: 세 변수 다 Y에게 영향을 준다.


# 3단계 : X는 Y에게 어떠한 영향을 주는가?

# RANK는 다른 X들이 고정되어 있을 때에 RANK의 기본단위가(단위를 잘 봐야함) 1 증가하면(만약 단위가 $면 '1$가 증가하면'이라고 표현해야 함)(나머지 다른 2개 조건 들은 가만히 있고 RANK만 움직이는 걸 '다른 X들이 고정되어 있을 때'라고 표현한 거임)
# Y를 약 0.000 정도 증가시키고, 
# MOBILE_SCCNT_VALUE는, 다른 X들이 고정되어 있을 때에 MOBILE_SCCNT_VALUE의 기본단위가
# 1 증가하면 Y를 약 1 정도 증가시키고,
# PC_SCCNT_VALUE는, 다른 X들이 고정되어 있을 때에 PC_SCCNT_VALUE의 기본단위가
# 1 증가하면 Y를 약 1 정도 증가시키는 것으로 나타났다. 


# 4단계 : 회귀 모형의 설명력 = X들의 설명력
# Y안에 다름(변도)이 있는데, 이 달므을 X들이 얼마나 설명하고 있는가? <- 이게 설명력이고 많이 설명할 수록 좋은 거임, 설명력이 좋다면 X들이 중요하다는 거임
# Multiple R-squared:      1,	Adjusted R-squared:      1 
# X들이 모두 유의한 영향을 주면 R-Square를 보고
# X들 중에 일부는 유의한 영향을 주지 않으면 Adjusted R-squared를 본다.
# X들이 Y의 변동(다름)을 100% 설명하고 있다.  <- 사실 100% 나오는 경우 거의 없지


# 왜냐면, R-Square는 미미하지만 무조건 증가하는 성질이 있음. 그럼 무조건 X를 많이 넣으면 이게 커짐
# Adjusted R-squared는 유의하지 않으면 패널티를 줘서 이게 유의하지 않도록 막는 패널티가 있음

# 우리처럼 다 X들이 유의하면 그냥 R-Square 써도 됨


# 5단계 : 예측
predict(culture_model,
        data.frame(RANK = 5,
                   MOBILE_SCCNT_VALUE = 100,
                   PC_SCCNT_VALUE     = 200))
# Y는 이제까지 학습한 거로 보면 300이 나올 거 같다! 라고 예측한 거임





