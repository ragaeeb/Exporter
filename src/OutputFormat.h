#ifndef OUTPUTFORMAT_H_
#define OUTPUTFORMAT_H_

#include <qobjectdefs.h>

namespace exportui {

class OutputFormat
{
    Q_GADGET
    Q_ENUMS(Type)

public:
    enum Type {
        CSV,
        TXT
    };
};

}

#endif /* OUTPUTFORMAT_H_ */
