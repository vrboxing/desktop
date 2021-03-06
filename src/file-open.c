#include <errno.h>
#include <libgen.h>  // for basename
#include <limits.h>
#include <linux/limits.h>  // for PATH_MAX
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int get_graphic_display(char* display, size_t size) {
  FILE* fp = popen("~/bin/tty-ctl graphic-display", "r");
  if (NULL == fp) {
    perror("popen");
    return errno;
  }
  memset(display, '\0', size);
  fgets(display, size, fp);
  char* eol = strchr(display, '\n');
  if (eol) {
    *eol = '\0';
  }
  int status = pclose(fp);
  status = ((status == -1 || !WIFEXITED(status)) ? EXIT_FAILURE
                                                 : WEXITSTATUS(status));
  if (status != 0) {
    fprintf(stderr, "Graphic display not found\n");
    return EXIT_FAILURE;
  }
  return status;
}

void guess_file_extension(const char* file, char* extension,
                          int extension_size) {
  memset(extension, 0, extension_size);
  char command[255] = {'\0'};
  snprintf(command, sizeof(command), "file -b --extension %s", file);
  FILE* f = popen(command, "r");
  if (f != NULL) {
    fgets(extension, extension_size, f);
    char* end = strchr(extension, '\n');
    if (end) {
      *end = '\0';
    }
    end = strchr(extension, '/');
    if (end) {
      *end = '\0';
    }
    pclose(f);
  }
}

void get_file_extension(const char* file, char* extension, int extension_size) {
  memset(extension, 0, extension_size);
  char path[PATH_MAX] = {'\0'};
  strncpy(path, file, sizeof(path) - 1);
  const char* name = basename(path);
  const char* dot = strrchr(name, '.');
  if (dot) {
    snprintf(extension, extension_size, "%s", dot + 1);
  }
}

const char* get_console_program(const char* extension) {
  if (strcasecmp(extension, "pdf") == 0) {
    return "`which fbpdf-reader || which fbpdf2`";
  }
  if (strcasecmp(extension, "jpg") == 0 || strcasecmp(extension, "jpeg") == 0 ||
      strcasecmp(extension, "ppm") == 0 || strcasecmp(extension, "tiff") == 0 ||
      strcasecmp(extension, "xwd") == 0 || strcasecmp(extension, "bmp") == 0 ||
      strcasecmp(extension, "png") == 0 || strcasecmp(extension, "webp") == 0) {
    return "fbi -a";
  }
  if (strcasecmp(extension, "gif") == 0) {
    return "mplayer -vo fbdev2 -msglevel all=0 -fs -loop 0";
  }
  if (strcasecmp(extension, "3g2") == 0 || strcasecmp(extension, "3gp") == 0 ||
      strcasecmp(extension, "asf") == 0 || strcasecmp(extension, "ask") == 0 ||
      strcasecmp(extension, "avi") == 0 || strcasecmp(extension, "c3d") == 0 ||
      strcasecmp(extension, "dat") == 0 || strcasecmp(extension, "divx") == 0 ||
      strcasecmp(extension, "dvr-ms") == 0 ||
      strcasecmp(extension, "f4v") == 0 || strcasecmp(extension, "flc") == 0 ||
      strcasecmp(extension, "fli") == 0 || strcasecmp(extension, "flv") == 0 ||
      strcasecmp(extension, "flx") == 0 || strcasecmp(extension, "m2p") == 0 ||
      strcasecmp(extension, "m2t") == 0 || strcasecmp(extension, "m2ts") == 0 ||
      strcasecmp(extension, "m2v") == 0 || strcasecmp(extension, "m4v") == 0 ||
      strcasecmp(extension, "mkv") == 0 || strcasecmp(extension, "mlv") == 0 ||
      strcasecmp(extension, "mov") == 0 || strcasecmp(extension, "mp4") == 0 ||
      strcasecmp(extension, "mpe") == 0 || strcasecmp(extension, "mpeg") == 0 ||
      strcasecmp(extension, "mpg") == 0 || strcasecmp(extension, "mpv") == 0 ||
      strcasecmp(extension, "mts") == 0 || strcasecmp(extension, "ogm") == 0 ||
      strcasecmp(extension, "qt") == 0 || strcasecmp(extension, "ra") == 0 ||
      strcasecmp(extension, "rm") == 0 || strcasecmp(extension, "rmvb") == 0 ||
      strcasecmp(extension, "swf") == 0 || strcasecmp(extension, "tp") == 0 ||
      strcasecmp(extension, "trp") == 0 || strcasecmp(extension, "ts") == 0 ||
      strcasecmp(extension, "uis") == 0 || strcasecmp(extension, "uisx") == 0 ||
      strcasecmp(extension, "uvp") == 0 || strcasecmp(extension, "vob") == 0 ||
      strcasecmp(extension, "vsp") == 0 || strcasecmp(extension, "webm") == 0 ||
      strcasecmp(extension, "wmv") == 0 ||
      strcasecmp(extension, "wmvhd") == 0 ||
      strcasecmp(extension, "wtv") == 0 || strcasecmp(extension, "xvid") == 0) {
    return "mplayer -vo fbdev2 -msglevel all=0 -fs";
  }
  return NULL;
}

int console_open(const char* file, uid_t uid, gid_t gid) {
  char extension[10] = {'\0'};
  get_file_extension(file, extension, sizeof(extension));
  const char* program = get_console_program(extension);
  if (program == NULL) {
    guess_file_extension(file, extension, sizeof(extension));
    program = get_console_program(extension);
    if (program == NULL) {
      return EXIT_FAILURE;
    }
  }

  char command[PATH_MAX] = {'\0'};
  snprintf(command, sizeof(command),
           "openvt -s -w -- sudo -u `id -nu %d` -g `id -ng %d` %s '%s'", uid,
           gid, program, file);
  int status = system(command);
  status = ((status == -1 || !WIFEXITED(status)) ? EXIT_FAILURE
                                                 : WEXITSTATUS(status));

  return status;
}

int graphic_open(const char* file) {
  char command[PATH_MAX] = {'\0'};
  const char* display = getenv("DISPLAY");
  if (display == NULL || display[0] == '\0') {
    system("~/bin/tty-ctl other");
  }

  char graphic_display[32] = {'\0'};
  int status = get_graphic_display(graphic_display, sizeof(graphic_display));
  if (0 == status) {
    snprintf(command, sizeof(command),
             "DISPLAY=%s xdg-open '%s' >/dev/null 2>&1 &", graphic_display,
             file);
    int status = system(command);
    status = ((status == -1 || !WIFEXITED(status)) ? EXIT_FAILURE
                                                   : WEXITSTATUS(status));
  }
  return status;
}

int main(int argc, char* argv[]) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <file>\n", argv[0]);
    return EXIT_FAILURE;
  }

  const char* display = getenv("DISPLAY");
  if (display && display[0] != '\0') {
    return graphic_open(argv[1]);
  }

  char file[PATH_MAX] = {'\0'};
  if (NULL == realpath(argv[1], file)) {
    fprintf(stderr, "Error: file \"%s\" not exists\n", argv[1]);
    return EXIT_FAILURE;
  }

  const uid_t uid = getuid();
  const uid_t gid = getgid();
  if (setuid(0) == -1) {
    perror("setuid");
    return EXIT_FAILURE;
  }
  if (setgid(0) == -1) {
    perror("setgid");
    return EXIT_FAILURE;
  }

  int status = console_open(file, uid, gid);

  // Fallback to graphic_open if file not support to open in console.
  if (status == EXIT_FAILURE) {
    setuid(uid);
    setgid(gid);
    status = graphic_open(file);
  }

  return status;
}
