#ifndef LOGGER_H_
#define LOGGER_H_

//#define DEBUG 1

#ifdef DEBUG
#define LOGGER(a) qDebug() << a;
#else
#define LOGGER(a)
#endif

#endif /* LOGGER_H_ */
