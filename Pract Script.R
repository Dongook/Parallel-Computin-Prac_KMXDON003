install.packages("foreach")
install.packages("doParallel")

library(foreach)
library(doParallel)

## Question 1

# Set up parallel backend
cl <- makeCluster(detectCores() - 1) # 전체 코어 개수에서 1개를 남겨두고 나머지를 병렬 처리에 사용. 이유: 시스템이 완전히 멈추지 않게 하기 위해 하나의 코드 남기는 것 일반적 (makeCluster(n): n개의 코어를 사용하여 병렬 클러스터 생성)
registerDoParallel(cl) # 병렬 백엔드 등록

# Number of repetitions
n <- 100

# Run parallel foreach loop
# 100번 반복, 병렬 실행(%dopar%), .combine = rbind(결과를 행 단위로 결함함)
run <- foreach(i = 1:n, .combine = rbind) %dopar% {
  sample.data <- rexp(100, rate = 1) # Generate sample from Exp(1)
  sample.mean <- mean(sample.data) # Calculate mean
  sample.var <- var(sample.data) # Calculate variance
  c(sample.mean, sample.var) # Return results as vector
}

# Convert results to a data frame
df <- as.data.frame(run)
colnames(df) <- c("Mean", "Variance")

# Print first few rows
head(df)

# Stop the cluster
stopCluster(cl)

## Question 2

# Load the galaxies dataset
library(MASS)
data(galaxies)
dat <- galaxies

# Number of bootstrap iterations
B <- 10000 
b <- 1000 # Number of samples per batch

# --- SERIAL BOOTSTRAP ---
serial.s <- Sys.time() # Start timing

serial.r <- numeric(B)
for (i in 1:B){
  resample <- sample(dat, replace = TRUE) # Bootstrap resample
  serial.r[i] <- median(resample) # Compute median
}

serial.e <- Sys.time() # End timing
serial.t <- serial.e - serial.s
cat("Serial Processing Time", serial.t)

# --- PARALLEL BOOTSTRAP ---
cl <- makeCluster(detectCores() - 1)
registerDoParallel(cl)

parallel.s2 <- Sys.time()

parallel.r2 <- foreach(i = 1:B, .combine = c, .packages = "MASS") %dopar% {
  resample <- sample(dat, replace = TRUE)
  median(resample)
}

parallel.e2 <- Sys.time()
stopCluster(cl)

parallel.t2 <- parallel.e2 - parallel.s2
cat("Paralle Processing Time", parallel.t2)
