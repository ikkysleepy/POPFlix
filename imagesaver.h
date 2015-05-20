#ifndef IMAGESAVER_H
#define IMAGESAVER_H

#include <QObject>

class ImageSaver : public QObject
{
    Q_OBJECT
public:
    explicit ImageSaver(QObject *parent = 0);

signals:

public slots:
    void save(QObject *item, const QString &url);
    int exist(const QString &url);
    static bool removeDir(const QString &dirName);
    int dir_size(const QString &dirName);

};

#endif // IMAGESAVER_H
