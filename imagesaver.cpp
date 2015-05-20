#include "imagesaver.h"
#include <QtGui/QApplication>
#include <QtDeclarative>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFileInfoList>

ImageSaver::ImageSaver(QObject *parent) : QObject(parent)
{
    //do nothing here
}


int ImageSaver::exist(const QString &path)
{
    // Determine if file exist
    if(QFile(path).exists())
        return 1;
    else
        return 0;
}

void ImageSaver::save(QObject *imageObj, const QString &path)
{
    QGraphicsObject *item = qobject_cast<QGraphicsObject*>(imageObj);

    if (!item) {
        qDebug() << "Item is NULL";
        return;
    }

    QString cache = "/home/user/popflix/cache/";

    // Create Cache folder
    if(!QDir(cache).exists())
    {
        QDir().mkdir("/home/user/popflix");
        QDir().mkdir(cache);
    }

    QImage img(item->boundingRect().size().toSize(), QImage::Format_RGB32);
    img.fill(QColor(255, 255, 255).rgb());
    QPainter painter(&img);
    QStyleOptionGraphicsItem styleOption;
    item->paint(&painter, &styleOption);
    img.save(path);
}


/*!
   Delete a directory along with all of its contents.

   \param dirName Path of directory to remove.
   \return true on success; false on error.
*/
bool ImageSaver::removeDir(const QString &dirName)
{
    bool result = true;
    QDir dir(dirName);

    if (dir.exists(dirName)) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir()) {
                result = removeDir(info.absoluteFilePath());
            }
            else {
                result = QFile::remove(info.absoluteFilePath());
            }

            if (!result) {
                return result;
            }
        }
        result = dir.rmdir(dirName);
    }

    return result;
}

int ImageSaver::dir_size(const QString &path)
{
    long int sizex = 0;
    QFileInfo str_info(path);
    if (str_info.isDir())
    {
    QDir dir(path);
    QStringList ext_list;
    dir.setFilter(QDir::Files | QDir::Dirs |  QDir::Hidden | QDir::NoSymLinks);
    QFileInfoList list = dir.entryInfoList();
    for (int i = 0; i < list.size(); ++i)
            {
                QFileInfo fileInfo = list.at(i);
                if ((fileInfo.fileName() != ".") && (fileInfo.fileName() != ".."))
                {
                    if(fileInfo.isDir())
                    {
                        sizex += this->dir_size(fileInfo.filePath());
                        QApplication::processEvents();
                    }
                    else
                    {
                        sizex += fileInfo.size();
                        QApplication::processEvents();
                    }

                }
            }

    }
    return sizex;
}
