# 1. 패키지 설치하기와 로딩하기 ----
install.packages("readxl")
install.packages("writexl")
install.packages("tidyverse")
library(readxl)
library(writexl)
library(tidyverse)


# 2. 작업공간 설정하기 ----
setwd("d:/KCISA")
getwd


# 3. 데이터 읽어오기
culture <- readxl::read_excel(path      = "culture.xlsx",
                              sheet     = "DM",
                              col_names = TRUE)


# 4. 데이터 전체 보기 ----
# View(data)
View(culture)


# 5. 데이터의 일부 보기 ----
# 콘솔에 출력이 됨
# 5.1 head(data, n =6) ----
head(culture)
head(culture, n = 10)


# 5.2 tail(data, n =6) ----
tail(culture)
tail(culture, n = 10)


# 6. 데이터의 구조(Structure) ----
# dplyr::glimpse(data) # 데이터를 대충 훑어보는 것
dplyr::glimpse(culture)
# <dbl> :  double임 소수점을 갖는 숫자로 되어있구나!


# 7. 입력오류 체크하기 ----
# summary(data) 데이터에 입력이 잘 되었는지 아닌지를 체크
summary(culture)    # Rank는 min과 max만 봐도 됨. 

# 문자열은 체크가 어려우니 factor로 만든 뒤 다시 summary로 확인해 본다
culture$SRCHWRD_NM <- as.factor(culture$SRCHWRD_NM)  
culture$UPPER_CTGRY_NM <- as.factor(culture$UPPER_CTGRY_NM)
culture$LWPRT_CTGRY_NM <- as.factor(culture$LWPRT_CTGRY_NM)


# 8. 데이터의 속성 ----
# 데이터 : 2차원 구조의 데이터
# 행과 열로 구성되어 있음
# data.frame, tibble, data.table   <- data.frame과 tibble을 data.table의 형태로 바꾸면 분석 속도가 굉장히 빠르게 끝남
# 참고 : 패키지 : data.table
# 참고 : SQL      <-DB랑 바로 커뮤니케이션 해서 DB에서 바로 가져올 수 있음. 속도면에서 좋음 


# 8.1 행의 개수 ----
# nrow(data)
nrow(culture)


# 8.2 열(Column) = 변수(Variable) = Feature = Label ----
# ncol(data)
ncol(culture)


# 8.3 열의 이름 ----
# colnames(data)
colnames(culture)


# 9. 데이터 슬라이싱(Data Slicing) ----
# 9.1 열 ----
# dplyr::select(data, variable)
# data %>% dplyr::select(variable)
culture %>%
  dplyr::select(RANK)

culture %>% 
  dplyr::select(RANK, SCCNT_SM_VALUE)

culture %>%
  dplyr::select(RANK:SCCNT_SM_VALUE)  # 여러개를 한 번에

culture %>% 
  dplyr::select(-RANK)  # RANK를 뺀 나머지를 다 가져옴

culture %>% 
  dplyr::select(-c(RANK, SCCNT_SM_VALUE))

# 변수명에 특정한 패턴이 있는 경우
# i. 변수명에 'p'라는 문자가 있는 경우
culture %>% 
  dplyr::select(contains("P"))

# ii. 변수명이 'S'라는 문자로 시작하는 경우
culture %>% 
  dplyr::select(starts_with("S"))

# iii. 변수명이 'E'라는 문자로 끝나는 경우
culture %>% 
  dplyr::select(ends_with("E"))


# 9.2 행 ----
# dplyr::filter(data, 조건)
# data %>% dplyr::filter(조건)

# (1) RANK가 5이하인 데이터
culture %>% 
  dplyr::filter(RANK <= 5)  # 비교 연산자 조건에 맞는 것을 잘라내는 것것


# (2) LWPRT_CTGRY_NM이 "연극"인 데이터
culture %>% 
  dplyr::filter(LWPRT_CTGRY_NM == "연극")


# (3) RANK가 5이하이고,  LWPRT_CTGRY_NM은 "연극"인 데이터
culture %>% 
  dplyr::filter(RANK <= 5, LWPRT_CTGRY_NM == "연극")

  
# (4) RANK가 5이거나 또는  LWPRT_CTGRY_NM은 "연극"인 데이터
# tibble은 data를 의미한다.
culture %>% 
  dplyr::filter(RANK <= 5 | LWPRT_CTGRY_NM == "연극") 


# 여기까지 가공한 데이터를 보고 싶다면 이렇게 하자!
culture %>% 
  dplyr::filter(RANK <= 5 | LWPRT_CTGRY_NM == "연극") %>% 
  View()


# 9.3 행과 열 ----
# RANK가 5이하이고,  LWPRT_CTGRY_NM은 "연극"인 데이터의
# 'E'라는 문자로 끝나는 열
# 행과 열을 잘라낸 때는 항상 행부터(filter) 잘라내준다.
culture %>% 
  dplyr::filter(RANK <= 5, LWPRT_CTGRY_NM == "연극") %>%
  dplyr::select(ends_with("E")) -> culture2    # 다른 변수에 이걸 저장해줌

# %>% 를 사용하면 순서대로 무슨 작업을 했는지 한눈에 단계별로 볼 수 있음
# 중간에 불필요한 데이터를 생성하지 않고 우리가 원하는 최종적인 데이터를 만들어낼 수 있음
# 중간에 데이터가 생기는 게 안 좋은 이유는? 메모리를 차지하기 때문에.
# 실전에서 데이터가 너무 크면 메모리 용량을 너무 많이 차지하게 된다.


# 10. 새로운 변수 만들기 ----
# dplyr::mutate(new_variable = )
# 10.1 연산 ----
culture %>% 
  dplyr::mutate(TOTAL_VALUE = MOBILE_SCCNT_VALUE + PC_SCCNT_VALUE + SCCNT_SM_VALUE) -> culture 
# 이걸 해줘야 culture에 덮어쓰기가 된다. 그래야 TOTAL_VALUE라는 컬럼이 생김.
#이걸 안 해주면 그냥 이 작업만 한 거임. 

# 10.2 변환 ----
# (1) 로그 변환 
# (2) 루트 변환
# (3) 역수 변환
culture %>% 
  dplyr::mutate(total_log10   = log10(TOTAL_VALUE),
                total_root    = sqrt(TOTAL_VALUE),
                total_inverse = 1/TOTAL_VALUE) -> culture
View(culture)



# 10.3 범주(집단) 줄이기 ----
# 10.4 구간정보를 갖는 변수 ----





  





















