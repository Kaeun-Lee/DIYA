# 1. 패키지 설치하기와 로딩하기 ----
install.packages("readxl")
install.packages("writexl")
install.packages("tidyverse")
install.packages("e1071")
library(readxl)
library(writexl)
library(tidyverse)
library(e1071)

# 2. 작업공간 설정하기 ----
setwd("d:/KCISA")
getwd


# 3. 데이터 읽어오기
culture <- readxl::read_excel(path      = "culture.xlsx",
                              sheet     = "DM",
                              col_names = TRUE)


# 4. EDA(Exploratory Data Analysis) = 탐색적 데이터 분석 ----
# 전체, 집단, 타켓, 개인별로 아주 철저하게 볼 줄 알아야함! 그래야 insight를 얻을 수 있음
# 4.1 일변량 질적 자료의 분석 ----
# 일변량 : Uni-Variate(하나의 변하는 어떤 값)   / 변하지 않는 것은 '상수'임
# 하나의 열 = 하나의 변수 = 하나의 Feature = 하나의 Label
# 질적 자료 = 범주형 자료 : 문자 또는 숫자(숫자의 의미가 없다)

# (1) 표 = 빈도표(Frequency Table)  (통계학에서는 '도수분포표'라고 함)
# i.  빈도(Frequency) : 이 값이 몇 개가 있는지 하나한 센 것 
# ii. 백분율(Percent) : 하나하나에 관심이 있는 게 아니라, 전체를 100으로 봤을 때 어떤 하나가 전체의 얼마를 차지하는지를 알고 싶은 것 (빈도/합계)*!00

# SRCHWRD_NM
culture %>% 
  dplyr::count(SRCHWRD_NM, sort = TRUE) %>%     # 가장 검색을 많이 한 순으로 내림차순
  dplyr::mutate(percent = round((n/sum(n))*100, digits = 1)) %>% 
  writexl::write_xlsx(path = "SRCHWRD_NM.xlsx")


# 1.2 그래프 ----
# (1) 막대그래프

# (2) 원그래프


# LWPRT_CTGRY_NM
culture %>% 
  ggplot2::ggplot(mapping = aes(x = LWPRT_CTGRY_NM)) +       # aes(x)는 세로 그래프, aes(y)는 가로 그래프
  ggplot2::geom_bar(fill = "red") +                          # fill = "purple"
  ggplot2::theme_classic() +                                 # 뒤에 격자 무늬를 없애줌
  ggplot2::labs(title = "하위 카테고리명의 현황",            # title : 차트의 제목
                x     = "하위 카테고리명",
                y     = "Frequency") +
  ggplot2::theme(plot.title = element_text(size  = 20,
                                           color = "red",
                                           face  = "bold",
                                           hjust = 0.5),     # 가운데를 정리해준다. 0.5가 가운데임
                 axis.title.x = element_text(size = 15,      # axis.title.x : x축의 제목
                                             face = "italic"),
                 axis.title.y = element_text(size = 15,
                                             face = "bold.italic",
                                             angle = 0,      # y축 글씨를 세로가 아닌 가로로 해준다
                                             vjust = 0.5)) + # 세로 가운데 정렬
  ggplot2::ggsave(filename = "LWPRT_CTGRY_NM.jpeg",
                  width    = 5,       # 가로 5 inch
                  height   = 5,       # 세로 5 inch
                  units    = "in")    # units의 디폴트 크기가 inch다

# 참고
# units : "in", "cm", "mm"
# "in" : inch 

  
# 4.2 일변량 양적 자료의 분석 ----
# 양적 자료 : 수치형 자료(Numerical data)
# (1) 표 = 빈도표
# i.  구간의 빈도
# ii. 구간의 백분율

# 내거는 오류나서 02Lecture에서 했던 거 다시 불러옴
culture <- readxl::read_excel(path      = "culture.xlsx",
                              sheet     = "DM",
                              col_names = TRUE)

culture %>%
  dplyr::mutate(TOTAL_VALUE = MOBILE_SCCNT_VALUE + PC_SCCNT_VALUE + SCCNT_SM_VALUE) -> culture


culture %>%
  dplyr::mutate(total_log10   = log10(TOTAL_VALUE),
                total_root    = sqrt(TOTAL_VALUE),
                total_inverse = 1/TOTAL_VALUE) -> culture



# 최소값, 최대값
min(culture$TOTAL_VALUE)
max(culture$TOTAL_VALUE)

# 범위 : 최대값 - 최소값
RANGE <- max(culture$TOTAL_VALUE) - min(culture$TOTAL_VALUE)

# 구간의 개수 : Sturge's Formula
INTERVAl_N <- 1 + 3.3 * log10(length(culture$TOTAL_VALUE))

# 구간의 너비 : 범위 / 구간의 개수
INTERVAL_WIDTH <- RANGE / 13

culture %>%
  dplyr::mutate(TOTAL_VALUE = MOBILE_SCCNT_VALUE + PC_SCCNT_VALUE + SCCNT_SM_VALUE) -> culture

culture %>% 
  dplyr::mutate(total_group = cut(TOTAL_VALUE,
                                  breaks = seq(from = 50, to = 3690, by = 260),     # 구간의 정보를 준다
                                  right  = FALSE)) -> culture
View(culture)


culture %>% 
  dplyr::count(total_group, sort = TRUE) %>% # 가장 검색을 많이 한 순으로 내림차순
  dplyr::mutate(percent = round((n/sum(n)) * 100, digits = 1)) %>%  
  writexl::write_xlsx(path = "total_group.xlsx")



# (2) 그래프
# i.  히스토그램(Histogram)
culture %>% 
  ggplot2::ggplot(mapping = aes(x = TOTAL_VALUE)) +
  ggplot2::geom_histogram(fill = "red")

# 구간의 너비 : binwidth =
culture %>% 
  ggplot2::ggplot(mapping = aes(x = TOTAL_VALUE)) +
  ggplot2::geom_histogram(binwidth = 100)  # 0~100 , 101~ 200

# 구간의 개수 : bins =
culture %>% 
  ggplot2::ggplot(mapping = aes(x = TOTAL_VALUE)) +
  ggplot2::geom_histogram(bins = 10)  # 0~100 , 101~ 200



# ii. 상자그림(Boxplot)
# 이상치(outlier)가 잇는지를 파악하기 위해 작성함
culture %>% 
  ggplot2::ggplot(mapping = aes(y = TOTAL_VALUE)) +   # 상자는 보통 세로로 많이 함/ 가로축의 숫자는 의미없음
  ggplot2::geom_boxplot()


# (3) 기술통계량 = 요약통계량   # 구할 수 있다면 양적 자료로 구하는 게 좋긴 함
# i. 중심 = 대표값       : 평균, 절사평균(절삭평균), 중위수(중앙값), 최빈수(최빈값) 
# (대표값은 대표값과 대표를 당하는 값이 비슷하다는 뜻. 양적 자료의 중심이 어디있는가, 양적 자료의 대표값이 무엇인가, 평균을 구했다는 건 이 양정 자료를 대표하는 값을 구하고 싶다는 뜻이지만, 이상치의 영향을 어마어마하게 받는다)

culture %>% 
  dplyr::summarise(n           = n(),
                   Mean        = mean(TOTAL_VALUE),
                   TrimmedMean = mean(TOTAL_VALUE, trim = 0.05),   # 중위수
                   Median      = median(TOTAL_VALUE))   



# ii. 산포 = 퍼짐 = 다름 : 범위, 사분위범위, 표준편차, 중위수절대편차
culture %>% 
  dplyr::summarise(Range = max(TOTAL_VALUE, na.rm = TRUE) - min(TOTAL_VALUE),    # 결측치 제거
                   IQR   = IQR(TOTAL_VALUE),
                   SD    = sd(TOTAL_VALUE),      # 표준편차, 여기에서는 평균과 약 500가까이의 차이가 남
                   MAD   = mad(TOTAL_VALUE))     # 중위수절대편차, 중위수와 약 359 정도 다르구나를 알 수 있음



# iii. 분포의 모양       : 왜도, 첨도
# 기본기능에서는 왜도와 첨도를 못 구한다.
# 패키지 : e1071
culture %>% 
  dplyr::summarise(SKEW = e1071::skewness(TOTAL_VALUE),    # summarise: 기술 통계량
                   KURT = e1071::kurtosis(TOTAL_VALUE)) 


# 4.3 이변량 자료의 분석(질적 자료 vs 양적 자료) ----
# 이변량    : Bi-Variate
# 다변량    : Multiple-Variate : 3개 이상
# 질적 자료 : 집단
# 집단 별 양적인 자료의 분석

# (1) 집단별 그래프
# i. 집단별 히스토그램
culture %>% 
  ggplot2::ggplot(mapping = aes(x = TOTAL_VALUE)) +    # 주로 x 에는 양적 자료를 넣어준다
  ggplot2::geom_histogram() +
  ggplot2::facet_wrap(~LWPRT_CTGRY_NM)

# ii. 집단별 상자그림
culture %>% 
  ggplot2::ggplot(mapping = aes(y = TOTAL_VALUE)) +    
  ggplot2::geom_boxplot(outlier.colour = "red") +
  ggplot2::facet_wrap(~LWPRT_CTGRY_NM)

# iii. 집단별 바이올린 그림
culture %>% 
  ggplot2::ggplot(mapping = aes(x = LWPRT_CTGRY_NM,
                                y = TOTAL_VALUE,
                                fill = LWPRT_CTGRY_NM)) +    
  ggplot2::geom_violin()


# (2) 집단별 기술통계량

culture %>% 
  dplyr::group_by(LWPRT_CTGRY_NM) %>% 
  dplyr::summarise(n           = n(),
                   Mean        = mean(TOTAL_VALUE),
                   Median      = median(TOTAL_VALUE)) %>% 
  dplyr::arrange(desc(Mean))  %>%     # 내림차순으로 정렬
  writexl::write_xlsx(path = "statistics_by.xlsx")


culture %>% 
  dplyr::group_by(LWPRT_CTGRY_NM, SRCHWRD_NM) %>%   # 두 열의 그룹이 곱하기가 되는 거임
  dplyr::summarise(n           = n(),
                   Mean        = mean(TOTAL_VALUE),
                   Median      = median(TOTAL_VALUE)) %>% 
  dplyr::arrange(desc(Mean))  






