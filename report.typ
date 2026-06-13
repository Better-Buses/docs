#import "lib/common.typ": course, prjName
#import "lib/reportLib.typ": config, firstPage, tableOfContentPage

#firstPage(prjName)

#tableOfContentPage(tableList: false)

#show: config.with()

#include "chapters/abstract.typ"
#include "chapters/architecture.typ"
