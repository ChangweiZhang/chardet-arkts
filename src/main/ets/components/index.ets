import { Match } from './match';
import { Recogniser, Context } from './encoding';
import { BusinessError } from '@ohos.base';
//import loadFs from './fs/node';

import Ascii from './encoding/ascii';
import Utf8 from './encoding/utf8';
import * as unicode from './encoding/unicode';
import * as mbcs from './encoding/mbcs';
import * as sbcs from './encoding/sbcs';
import * as iso2022 from './encoding/iso2022';
import { isByteArray } from './utils';
import fs from "@ohos.file.fs"

interface FullOptions {
  sampleSize: number;
  offset: number;
}

export type Options = Partial<FullOptions>;

const recognisers: Recogniser[] = [
  new Utf8(),
  new unicode.UTF_16BE(),
  new unicode.UTF_16LE(),
  new unicode.UTF_32BE(),
  new unicode.UTF_32LE(),
  new mbcs.sjis(),
  new mbcs.big5(),
  new mbcs.euc_jp(),
  new mbcs.euc_kr(),
  new mbcs.gb_18030(),
  new iso2022.ISO_2022_JP(),
  new iso2022.ISO_2022_KR(),
  new iso2022.ISO_2022_CN(),
  new sbcs.ISO_8859_1(),
  new sbcs.ISO_8859_2(),
  new sbcs.ISO_8859_5(),
  new sbcs.ISO_8859_6(),
  new sbcs.ISO_8859_7(),
  new sbcs.ISO_8859_8(),
  new sbcs.ISO_8859_9(),
  new sbcs.windows_1251(),
  new sbcs.windows_1256(),
  new sbcs.KOI8_R(),
  new Ascii(),
];

export type AnalyseResult = Match[];

export type DetectResult = string | null;

export const detect = (buffer: Uint8Array): string | null => {
  const matches: Match[] = analyse(buffer);
  return matches.length > 0 ? matches[0].name : null;
}

export const analyse = (buffer: Uint8Array): AnalyseResult => {
  if (!isByteArray(buffer)) {
    throw new Error('Input must be a byte array, e.g. Buffer or Uint8Array');
  }

  // Tally up the byte occurrence statistics.
  const byteStats: number[] = [];
  for (let i = 0; i < 256; i++) byteStats[i] = 0;

  for (let i = buffer.length - 1; i >= 0; i--) byteStats[buffer[i] & 0x00ff]++;

  let c1Bytes = false;
  for (let i = 0x80; i <= 0x9f; i += 1) {
    if (byteStats[i] !== 0) {
      c1Bytes = true;
      break;
    }
  }

  const context: Context = {
    byteStats,
    c1Bytes,
    rawInput: buffer,
    rawLen: buffer.length,
    inputBytes: buffer,
    inputLen: buffer.length,
  };

  const matches = recognisers
    .map((rec) => {
      return rec.match(context);
    })
    .filter((match) => {
      return !!match;
    })
    .sort((a, b) => {
      return b!.confidence - a!.confidence;
    });

  return matches as Match[];
};

export const detectFile = (
  filepath: string,
  opts: Options = {}
): Promise<DetectResult> =>
new Promise((resolve, reject) => {
  let fd: number;
  //const fs = loadFs();

  const handler = (err: Error | null | undefined, buffer: ArrayBuffer) => {
    if (fd) {
      fs.closeSync(fd);
    }

    if (err) {
      reject(err);
    } else {
      resolve(detect(new Uint8Array(buffer)));
    }
  };

  let file = fs.openSync(filepath, fs.OpenMode.READ_ONLY);
  fd = file.fd;
  let fileInfo = fs.statSync(fd);
  let bufferSize = fileInfo.size;
  if (opts && opts.sampleSize) {
    bufferSize = opts.sampleSize;
  }
  const sample: ArrayBuffer = new ArrayBuffer(bufferSize);

  fs.read(fd, sample,
    (err: BusinessError, readLen: number) => {
      handler(err, sample);
    }
  )
});

export const detectFileSync = (
  filepath: string,
  opts: Options = {}
): DetectResult => {
  let file = fs.openSync(filepath, fs.OpenMode.READ_ONLY);
  let fd = file.fd;
  let fileInfo = fs.statSync(fd);
  let bufferSize = fileInfo.size;
  if (opts && opts.sampleSize) {
    bufferSize = opts.sampleSize;
  }
  const sample: ArrayBuffer = new ArrayBuffer(bufferSize);
  let readLen = fs.readSync(fd, sample);
  fs.closeSync(fd);

  return detect(new Uint8Array(sample));

};


