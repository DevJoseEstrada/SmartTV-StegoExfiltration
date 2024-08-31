package com.devjmestrada.smarttvemitter

class BinService {

    private val contControlValue: Int = 3
    private val controlValue: Int = 2
    
    fun extractBinData(): List<Int> {
        val data: String = getInformation()
        return convertStringToBin(data)
    }

    private fun convertStringToBin(data: String): List<Int> {
        val binInformation = mutableListOf<Int>()
        for (char in data) {
            val code = char.code
            for (i in 7 downTo 0) {
                binInformation.add((code shr i) and 1)
            }
        }
        binInformation.addAll(List(contControlValue) { controlValue })
        return binInformation
    }

    private fun getInformation(): String {
        return "Hello world" // or Logic to extract some specific information
    }

}