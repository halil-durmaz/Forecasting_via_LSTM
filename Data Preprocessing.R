library         ("tidyr")        # gather için
library         ("dplyr")        # arrange, select için
library         ("lubridate")    # mdy için









#################################################################################################################
# 3 veri setini de R içine alalım. Kendi adlarındaki nesneler içinde tutalım. Dinamik olması için, linkten alalım
#################################################################################################################
confirmed = read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"), 
                     header=TRUE, 
                     check.names=FALSE)


deaths    = read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"), 
                      header=TRUE, 
                      check.names=FALSE)


recovered = read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"), 
                      header=TRUE, 
                      check.names=FALSE)



  







############################################################################################
# 3'ü için de, tarihleri "Date" değişkeni altında toplayalım (Wide format ---> Long format)
############################################################################################
long.confirmed = gather(confirmed, Date, Confirmed,    -c(1:4))
long.deaths    = gather(deaths   , Date, Deaths,       -c(1:4))
long.recovered = gather(recovered, Date, Recovered,    -c(1:4))












#################################################################################################
# Tüm bilgileri, 1 veri setinde birleştirelim
# Bir satırı diğer satırlardan spesifik olarak ayıran şey, Province & Country & Date değerleridir
#################################################################################################
dataset = merge(long.confirmed, long.deaths, 
                 by = c("Province/State", "Country/Region", "Lat", "Long", "Date"),
                 all=TRUE)


dataset = merge(dataset, long.recovered, 
                 by = c("Province/State", "Country/Region", "Lat", "Long", "Date"),
                 all=TRUE)














#######################################################
# Veri türlerimize bakalım. Uygunsuzlukları düzeltelim
#######################################################
str(dataset)

# Tarih verilerimizi karakter türünden Date türüne dönüştürelim
dataset$Date = mdy(dataset$Date)

# Güncel halini görelim
str(dataset)










#########################################################
# Ele almak istediğimiz ülkenin verilerini filtreleyelim
#########################################################

mycountry.dataset = dataset[dataset$`Country/Region` == 'Iran', ]
mycountry.dataset = mycountry.dataset[mycountry.dataset$`Province/State` == "", ]    # Farklı state'leri olan ülkelerin sorunu için

# Tarihe göre sıralat
mycountry.dataset = arrange(mycountry.dataset, 
                            Date)










######################################################################################################
# Sıradaki işlemimizde sorun yaratabilecek olan, "/" karakterli değişkenlerimizi yeniden adlandıralım
######################################################################################################
colnames(mycountry.dataset)[1:2] = c("Province.or.State","Country.or.Region")







######################################################################
# Her bir gün için, o gün gerçekleşen ölüm sayılarını verisetine ekle 
######################################################################
mycountry.dataset = mycountry.dataset %>% 
                    group_by(Province.or.State, Country.or.Region) %>% 
                    mutate(Daily.Deaths = lag(Deaths, 0) - lag(Deaths, 1))







#########################################################################
# Sadece projemiz için gerekli olan sütunlardan final veriseti yaratalım
#########################################################################
final.dataset = mycountry.dataset[ , c(5,9)]








############################################################
# Seçtiğim ülkenin verilerinde anormallikler var mı bakalım
############################################################

plot(final.dataset$Date,
     final.dataset$Daily.Deaths,
     type="l")







###########################################################
# Elde ettiğimiz verisetini .csv dosyası olarak kaydedelim
###########################################################
write.csv(final.dataset, 
          file="dataset.csv")



