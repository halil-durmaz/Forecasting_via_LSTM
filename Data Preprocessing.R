library         ("tidyr")        # gather i�in
library         ("dplyr")        # arrange, select i�in
library         ("lubridate")    # mdy i�in









#################################################################################################################
# 3 veri setini de R i�ine alal�m. Kendi adlar�ndaki nesneler i�inde tutal�m. Dinamik olmas� i�in, linkten alal�m
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
# 3'� i�in de, tarihleri "Date" de�i�keni alt�nda toplayal�m (Wide format ---> Long format)
############################################################################################
long.confirmed = gather(confirmed, Date, Confirmed,    -c(1:4))
long.deaths    = gather(deaths   , Date, Deaths,       -c(1:4))
long.recovered = gather(recovered, Date, Recovered,    -c(1:4))












#################################################################################################
# T�m bilgileri, 1 veri setinde birle�tirelim
# Bir sat�r� di�er sat�rlardan spesifik olarak ay�ran �ey, Province & Country & Date de�erleridir
#################################################################################################
dataset = merge(long.confirmed, long.deaths, 
                 by = c("Province/State", "Country/Region", "Lat", "Long", "Date"),
                 all=TRUE)


dataset = merge(dataset, long.recovered, 
                 by = c("Province/State", "Country/Region", "Lat", "Long", "Date"),
                 all=TRUE)














#######################################################
# Veri t�rlerimize bakal�m. Uygunsuzluklar� d�zeltelim
#######################################################
str(dataset)

# Tarih verilerimizi karakter t�r�nden Date t�r�ne d�n��t�relim
dataset$Date = mdy(dataset$Date)

# G�ncel halini g�relim
str(dataset)










#########################################################
# Ele almak istedi�imiz �lkenin verilerini filtreleyelim
#########################################################

mycountry.dataset = dataset[dataset$`Country/Region` == 'Iran', ]
mycountry.dataset = mycountry.dataset[mycountry.dataset$`Province/State` == "", ]    # Farkl� state'leri olan �lkelerin sorunu i�in

# Tarihe g�re s�ralat
mycountry.dataset = arrange(mycountry.dataset, 
                            Date)










######################################################################################################
# S�radaki i�lemimizde sorun yaratabilecek olan, "/" karakterli de�i�kenlerimizi yeniden adland�ral�m
######################################################################################################
colnames(mycountry.dataset)[1:2] = c("Province.or.State","Country.or.Region")







######################################################################
# Her bir g�n i�in, o g�n ger�ekle�en �l�m say�lar�n� verisetine ekle 
######################################################################
mycountry.dataset = mycountry.dataset %>% 
                    group_by(Province.or.State, Country.or.Region) %>% 
                    mutate(Daily.Deaths = lag(Deaths, 0) - lag(Deaths, 1))







#########################################################################
# Sadece projemiz i�in gerekli olan s�tunlardan final veriseti yaratal�m
#########################################################################
final.dataset = mycountry.dataset[ , c(5,9)]








############################################################
# Se�ti�im �lkenin verilerinde anormallikler var m� bakal�m
############################################################

plot(final.dataset$Date,
     final.dataset$Daily.Deaths,
     type="l")







###########################################################
# Elde etti�imiz verisetini .csv dosyas� olarak kaydedelim
###########################################################
write.csv(final.dataset, 
          file="dataset.csv")



