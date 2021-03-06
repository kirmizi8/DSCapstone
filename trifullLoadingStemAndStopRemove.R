# Start the clock!
ptm <- proc.time()

# SETUP #
setwd("C:/Users/Michael/SkyDrive/Code/GitHub/DSCapstone/Coursera-SwiftKey/final/en_US")
library(tm)
library(xtable)
library(RWeka)
options("max.print"=1000000)

# FUNCTION DEFINITIONS #

# Make Corpus, Transform, Make Trigram TDM
makeTDM <- function(x) {
corpus<-Corpus(VectorSource(x))
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, stemDocument)
corpus<- tm_map(corpus,removePunctuation)
corpus<- tm_map(corpus,removeNumbers)
tdm<- TermDocumentMatrix(corpus, control = list(tokenize = TgramTokenizer))
#tdm<-removeSparseTerms(tdm,0.97)
return(tdm)}

## DATA MUNGING ##

# 1. Corpus, transformations, and TDM Creation
#=============================================#

fileMunge<- function(x) {
text<-readLines(x)
totalLines=length(text)
chunkSize=20000
chunks=totalLines/chunkSize
remainder = chunks %% 1
wholeChunks = chunks-remainder
# initialize list
output=list()
# break file into chunks 
i=1
line=1
while (i<=wholeChunks){
end=line+chunkSize-1
output[[i]]<-text[line:end]
line=end+1
i=i+1
}
output[[i]]<-text[line:totalLines]
# Text Transformations to remove odd characters #
output=lapply(output,FUN=iconv, to='ASCII', sub=' ')
output=lapply(output,FUN= function(x) gsub("'{2}", " ",x))
output=lapply(output,FUN= function(x) gsub("[0-9]", " ",x))
}

TgramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))

# Read, chunk, parse data, then make corpus, do transformations, make TDM of tri-grams:
twit<-fileMunge("en_US.twitter.txt")
tTDM <- makeTDM(twit)
# rm(twit)
gc()

news<-fileMunge("en_US.news.txt")
nTDM <- makeTDM(news)
# rm(news)
gc()

blog<-fileMunge("en_US.blogs.txt")
bTDM <- makeTDM(blog)
# rm(blog)
gc()

# Stop the clock
proc.time() - ptm # 1255.23


ttdm2 <- removeSparseTerms(tTDM, 0.1)
ntdm2 <- removeSparseTerms(nTDM, 0.2)
btdm2 <- removeSparseTerms(bTDM, 0.1)

# top N words
m <- as.matrix(ttdm2)
v <- sort(rowSums(m), decreasing=TRUE)
tTop=v[10:1]

m <- as.matrix(ntdm2)
v <- sort(rowSums(m), decreasing=TRUE)
nTop=v[10:1]

m <- as.matrix(btdm2)
v <- sort(rowSums(m), decreasing=TRUE)
bTop=v[10:1]

saveRDS(tTop,"t3Top")
saveRDS(nTop,"n3Top")
saveRDS(bTop,"b3Top")
