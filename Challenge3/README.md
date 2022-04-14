### Challenge 3

We have a nested object, we would like a function that you pass in the object and a key and get back the value. How this is implemented is up to you.
Example Inputs
object = {“a”:{“b”:{“c”:”d”}}}
key = a/b/c
object = {“x”:{“y”:{“z”:”a”}}}
key = x/y/z
value = a

### Pre-requisites: 
1. Package need to install is jq which is used to parse json query

### Solution:
This script will ask nested object in json format as first input. Then user need to provide key value in appropriate format as second input. In last, correct value of Key will come as output in json format.
Attached Test Results.
