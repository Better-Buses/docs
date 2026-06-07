#import "lib/common.typ": course, prjName
#import "lib/reportLib.typ": config, firstPage, tableOfContentPage

#show: config.with()

#firstPage(prjName)

#tableOfContentPage(tableList: false)


#include "chapters/abstract.typ"
#include "chapters/architecture.typ"
