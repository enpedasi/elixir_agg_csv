using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace CsvAgg
{
    class Program {
        private static ConcurrentDictionary<string, int> wordMap;

        static void Main(string[] args)    {

            if (args.Length < 1)
            {
                Console.WriteLine("usage : ConsoleApp1.exe filename.csv");
            }

            var readFilePath = args[0];
            Stopwatch sw = new Stopwatch();

            sw.Start();
            Console.WriteLine("test start");
            wordMap = new ConcurrentDictionary<string, int> { };
            ProcessRead(readFilePath);

            Console.WriteLine(wordMap.Count);

            lock (wordMap)
            {
                var sorted = wordMap.OrderByDescending((x) => x.Value).Take(10);
                //var sorted = wordMap.OrderByDescending((x) => x.Value);

                sw.Stop();

                foreach (var rec in sorted)
                {
                    Console.WriteLine(rec.Key + ":" + rec.Value.ToString());
                }
            }
            var ts = sw.Elapsed;
            Console.WriteLine($"　{ts.Hours}時間 {ts.Minutes}分 {ts.Seconds}秒 {ts.Milliseconds}ミリ秒");
            Console.ReadKey(true);
        }


        static public async void ProcessRead(string filePath)
        {

            if (File.Exists(filePath) == false)
            {
                Debug.WriteLine("file not found: " + filePath);
            }
            else
            {
                try
                {
                    await ReadTextAsync(filePath);
                }
                catch (Exception ex)
                {
                    Debug.WriteLine(ex.Message);
                }
            }
        }

        static private async Task<ConcurrentDictionary<string, int>> ReadTextAsync(string filePath)
        {
            using (FileStream sourceStream = new FileStream(filePath,
                FileMode.Open
                , FileAccess.Read, FileShare.Read, bufferSize: 4096, useAsync: true
                ))
            {
                StreamReader sr = new StreamReader(sourceStream);
                string text;
                while ((text = await sr.ReadLineAsync()) != null)
                {
                    var wd = text.Replace("\"", string.Empty).Split(',')[1];
                    wordMap.AddOrUpdate(wd, 1, (_key, val) => { return val + 1; });
                }
                 return wordMap;
            }
        }
    }
}