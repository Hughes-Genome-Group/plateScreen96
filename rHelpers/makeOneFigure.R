args <- commandArgs(trailingOnly=TRUE)
mydata <- read.delim("temp.txt", header=T, sep="\t");
rownames(mydata) <- mydata[,1];
mydata <- as.matrix(mydata[,-1]);
png("testi.png", height=600, width=600); 
plot(mydata, type="b", xlab=args[1], ylab="PCR-count")
dev.off()



