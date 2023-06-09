library(tidyverse)
library(readxl)
library(readr)

#setwd("S:/DPR/02 - CGPR/Dashboards/Scripts/S�tima Rodada")


####---S�tima RODADA DE CONCESS�ES DE AEROPORTOS---####

####---------------BLOCO NORTE II---------------####


#rm(list = ls())


# Baixando a planilha do bloco diretamente do FTP
url = "ftp://ftpaeroportos.transportes.gov.br/SETIMA_RODADA/DADOS_047_20220223_EVTEA_pos_AP_novos_blocos/02%20Norte%20II/00%20Avalia%C3%A7%C3%A3o%20Econ%C3%B4mico-Financeira%20do%20Bloco%20Norte%20II/BlocoNorteII_Modelo_Financeiro_4.00.xlsm"
download.file(url, "BlocoNorteII_Modelo_Financeiro_4.00.xlsx", mode='wb')


# Fun��o para extrair informa��es de todos as abas dos aeroportos (tamb�m ser� usada para os outros blocos)
path = "BlocoNorteII_Modelo_Financeiro_4.00.xlsx"

read_excel_allsheets <- function(filename) {
  tamanho <- length(excel_sheets(path))                     # conta o total de abas
  sheets <- readxl::excel_sheets(filename)[14:(tamanho-2)]  # aplica a fun��o somente �s abas com informa��es de aeroportos (aba 12 at� a antepen�ltima)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

norteII <- read_excel_allsheets(path)                         # usa a fun��o para o bloco norte

names(norteII) <-  sub("Input_MF_", "",names(norteII))          # Muda o nome de cada dataframe para apenas o c�digo ICAO


# Fun��o para cada planilha de aeroporto, de modo a deix�-las no formato correto:
limpar_dataframe <- function(df){
  lapply(df, function(X){
    # Removendo linhas vazias (NA) ou desnecess�rias:
    X <- X[!apply(is.na(X) | X == "", 1, all),]
    X <- X[,-c(2:11,53:65)]
    icao <- names(X[1])
    # Transpondo e mantendo os nomes das linhas como nomes de colunas:
    n <- X[[1]]
    X <- as.data.frame(t(X[,-1]))
    #view(X)
    colnames(X) <- n
    X$Ano <- factor(row.names(X))
    rownames(X) <- NULL
    X$Ano <- as.numeric(paste(X$Ano))
    # Criando coluna com o c�digo ICAO:
    X["ICAO"] <- paste(icao)
    # Fazendo somat�rios para colunas que estavam vazias:
    X$Receitas <- rowSums(X[, c(8:9)])
    X$Dedu��es <- X$ISS
    X$Custos <- rowSums(X[, c(15:37)])
    X$`Capex de desenvolvimento` <- rowSums(X[, c(40:43)])
    X$`Capex de manuten��o` <- rowSums(X[, c(45:48)])
    X$CAPEX <- rowSums(X[, c(39,44)])
    X$Financiamento <- X$`Capta��es de financiamento (associado a Capex)`
    X$`Passageiros` <- X$`WLU com Passageiros` * 1000000
    X$`WLU` <- (X$`WLU com Passageiros` + X$`WLU com Carga`)*1000000
    #X$`Receitas Aeron�uticas / Passageiro` <- (X$`Receita aeron�utica`*1000000) / X$`Passageiros`
    #X$`Receitas Aeron�uticas / WLU` <- (X$`Receita aeron�utica`*1000000) / X$`WLU`
    X$`Receita N�o-Tarif�ria / Passageiro` <- (X$`Receita n�o-tarif�ria`*1000000) / X$`Passageiros`
    X$`Receita tarif�ria / Passageiro` <- (X$`Receita tarif�ria`*1000000) / X$`Passageiros`
    X$`Receita tarif�ria / WLU` <- (X$`Receita tarif�ria`*1000000) / X$`WLU`    
    X$`CAPEX / Passageiro` <- (X$CAPEX*1000000) / X$`Passageiros`
    X$`Custo total por WLU` <- (X$Custos*1000000) / X$`WLU`
    X$`Receita total por WLU` <- (X$Receitas*1000000) / X$`WLU`
    X$`Receita tarif�ria / Receita total` <- X$`Receita tarif�ria` / X$Receitas
    # Retirando colunas vazias (NA):
    X <- X[, !apply(is.na(X), 2, all),]
  })
}

norteII <- limpar_dataframe(norteII)                          # Aplica a fun��o de limpeza do dataframe para o bloco norte
norteII <- lapply(norteII, function(f) filter(f, Ano>2022 & Ano<2053))   # Filtra os anos para a partir de 2021 (in�cio das concess�es) e antes de 2053 (final das concess�es)


setima_norte_2 <- data.table::rbindlist(norteII)
save(setima_norte_2, file = "setima_norte_2.Rda")
rm(norteII)


####---------------BLOCO Avia��o Geral---------------####


#rm(list = ls())


# Baixando a planilha do bloco diretamente do FTP
url = "ftp://ftpaeroportos.transportes.gov.br/SETIMA_RODADA/DADOS_047_20220223_EVTEA_pos_AP_novos_blocos/03%20Avia%C3%A7%C3%A3o%20Geral/00%20Avalia%C3%A7%C3%A3o%20Econ%C3%B4mico-Financeira%20do%20Bloco%20Avia%C3%A7%C3%A3o%20Geral/BlocoAvia%C3%A7%C3%A3oGeral_Modelo_Financeiro_4.00.xlsm"
download.file(url, "BlocoAVG_Modelo_Financeiro_4.00.xlsx", mode='wb')

# Fun��o para extrair informa��es de todos as abas dos aeroportos (tamb�m ser� usada para os outros blocos)
path = "BlocoAVG_Modelo_Financeiro_4.00.xlsx"

AVG <- read_excel_allsheets(path)                         # usa a fun��o para o bloco central

names(AVG) <-  sub("Input_MF_", "",names(AVG))        # Muda o nome de cada dataframe para apenas o c�digo ICAO

AVG <- limpar_dataframe(AVG)                          # Aplica a fun��o de limpeza do dataframe para o bloco central
AVG <- lapply(AVG, function(f) filter(f, Ano>2022 & Ano<2053))   # Filtra os anos para a partir de 2021 (in�cio das concess�es)


setima_AVG <- data.table::rbindlist(AVG)
save(setima_AVG, file = "setima_AVG.Rda")
rm(AVG)


####---------------BLOCO SP/MS/PA/MG---------------####


#rm(list = ls())


# Baixando a planilha do bloco diretamente do FTP
url = "ftp://ftpaeroportos.transportes.gov.br/SETIMA_RODADA/DADOS_047_20220223_EVTEA_pos_AP_novos_blocos/01%20SP-MS-PA-MG/00%20Avalia%C3%A7%C3%A3o%20Econ%C3%B4mico-Financeira%20do%20Bloco%20SP-MS-PA-MG/BlocoSP.MS.PA.MG_Modelo_Financeiro_4.00.xlsm"
download.file(url, "BlocoSP.MS.PA.MG_Modelo_Financeiro_4.00.xlsx", mode='wb')

# Fun��o para extrair informa��es de todos as abas dos aeroportos (tamb�m ser� usada para os outros blocos)
path = "BlocoSP.MS.PA.MG_Modelo_Financeiro_4.00.xlsx"

SP_MS_PA_MG <- read_excel_allsheets(path)                         # usa a fun��o para o bloco sul

names(SP_MS_PA_MG) <-  sub("Input_MF_", "",names(SP_MS_PA_MG))            # Muda o nome de cada dataframe para apenas o c�digo ICAO

SP_MS_PA_MG <- limpar_dataframe(SP_MS_PA_MG)                              # Aplica a fun��o de limpeza do dataframe para o bloco sul
SP_MS_PA_MG <- lapply(SP_MS_PA_MG, function(f) filter(f, Ano>2022 & Ano<2053))       # Filtra os anos para a partir de 2021 (in�cio das concess�es)


setima_SP_MS_PA_MG <- data.table::rbindlist(SP_MS_PA_MG)
save(setima_SP_MS_PA_MG, file = "setima_SP_MS_PA_MG.Rda")
rm(SP_MS_PA_MG)




####Juntando os tr�s blocos da s�tima rodada####


#rm(list = ls())

load(file = "setima_AVG.Rda")
load(file = "setima_SP_MS_PA_MG.Rda")
load(file = "setima_norte_2.Rda")

setima_rodada <- rbind(setima_AVG, setima_SP_MS_PA_MG, setima_norte_2)
setima_rodada <- setima_rodada %>%
  arrange(ICAO, Ano)

save(setima_rodada, file = "setima_rodada.Rda")
rm(setima_AVG, setima_SP_MS_PA_MG, setima_norte_2)


####C�DIGO PARA INSERIR DADOS NO POWER BI####

#setwd("S:/DPR/02 - CGPR/Dashboards/Scripts/S�tima Rodada")
#load(file = "setima_rodada.Rda")


write_csv2(setima_rodada, 'teste.csv')
