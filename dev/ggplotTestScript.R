#alk meql
ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ALK"),], mapping = aes(x = titrationDate, y = alkMeqPerL)) +
  geom_point(aes(color = factor(sampleVolume))) +
  geom_line() +
  #meq/l thresholds from table
  geom_abline(slope = 0, intercept = 1, color = 'red') +
  geom_abline(slope = 0, intercept = 4, color = 'red') +
  geom_abline(slope = 0, intercept = 20, color = 'red') +
  labs(title = "Alkalinity, milliequivalents per liter",
       x = "Titraton Date",
       y = "ALK mEq/L") +
  scale_x_datetime(date_breaks = "4 months") +
  theme_bw() +
  theme(legend.title = element_blank(), 
        text = element_text(size = 14), 
        axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))

#anc meql
ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ANC"),], mapping = aes(x = titrationDate, y = ancMeqPerL)) +
  geom_point(aes(color = factor(sampleVolume))) +
  geom_line() +
  #meq/l thresholds from table
  geom_abline(slope = 0, intercept = 1, color = 'red') +
  geom_abline(slope = 0, intercept = 4, color = 'red') +
  geom_abline(slope = 0, intercept = 20, color = 'red') +
  labs(title = "Acid-neutralizing capacity, milliequivalents per liter",
       x = "Titraton Date",
       y = "ANC mEq/L") +
  theme_bw() +
  theme(text = element_text(size = 14), axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))

#alk mgl
ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ALK"),], mapping = aes(x = titrationDate, y = alkMgPerL)) +
  geom_point(aes(color = factor(sampleVolume))) +
  geom_line() +
  geom_abline(slope = 0, intercept = 50, color = 'red') +
  geom_abline(slope = 0, intercept = 200, color = 'red') +
  geom_abline(slope = 0, intercept = 1000, color = 'red') +
  labs(title = "Alkalinity, milligrams per liter",
       x = "Titraton Date",
       y = "ALK mg/L") +
  theme_bw() +
  theme(text = element_text(size = 14), axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))

#anc mgl
ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ANC"),], mapping = aes(x = titrationDate, y = ancMgPerL)) +
  geom_point(aes(color = factor(sampleVolume))) +
  geom_line() +
  geom_abline(slope = 0, intercept = 50, color = 'red') +
  geom_abline(slope = 0, intercept = 200, color = 'red') +
  geom_abline(slope = 0, intercept = 1000, color = 'red') +
  labs(title = "Acid-neutralizing capacity, milligrams per liter",
       x = "Titraton Date",
       y = "ANC mg/L") +
  theme_bw() +
  theme(text = element_text(size = 14), axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))