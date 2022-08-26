helpObject = {
  awk: "awk -F\' \' \'{print \$2}\'",
  reduce: "array.reduce((b,c) => b + c,0)"
}

console.log(helpObject[process.argv[2]])
